package Ocean::Standalone::Cluster::Backend::Context;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::Context';

use Ocean::Config::Loader;

use Ocean::Standalone::DB::FileManager;
use Ocean::Standalone::DB::Handler;

use Ocean::Standalone::Fixture::Schema::Default;
use Ocean::Standalone::Fixture::EvaluatorFactory;

use Ocean::Util::Image;
use Ocean::Util::String qw(gen_random);

use Try::Tiny;
use Digest::SHA1 qw(sha1_hex);
use Carp ();
use Log::Minimal;

sub service_initialize {
    my $self = shift;
    $self->log_info('setup db: %s', $self->config('db_file_path'));
    my $db_manager = $self->_create_db_manager();
    $db_manager->clear();
    $db_manager->setup();
}

sub worker_initialize {
    my $self = shift;

    $self->log_info('setup db: %s', $self->config('db_file_path'));

    my $db_handler = $self->_create_db_handler();
    $self->set('db' => $db_handler);

    # TODO make configurable
    my $fixtures = $self->_load_fixture();
    $self->_setup_database($fixtures);
}

sub _create_db_manager {
    my $self = shift;
    return Ocean::Standalone::DB::FileManager->new(
        file => $self->config('db_file_path'),
    );
}

sub _create_db_handler {
    my $self = shift;

    $self->log_info('prepare db handler: %s', $self->config('db_file_path'));
    my $dbh = Ocean::Standalone::DB::Handler->new(
        file => $self->config('db_file_path'),
    );
    $dbh->initialize();

    return $dbh;
}

sub _load_evaluator {
    my $self = shift;
    my $type = $self->config('fixture_evaluator') || 'yaml';
    my $factory = Ocean::Standalone::Fixture::EvaluatorFactory->new;
    my $evaluator = $factory->create_evaluator($type)
        or Carp::croak sprintf("Unknown evaluator type: %s", $type);
    return $evaluator;
}

sub _load_fixture {
    my $self = shift;

    my $filepath = $self->config('fixture_file_path');

    $self->log_info("prepare db fixture: %s", $filepath);

    unless (-e $filepath) {
        Carp::croak sprintf "fixture file '%s' not found", $filepath;
    }

    my $evaluator = $self->_load_evaluator();
    my $fixtures = $evaluator->evaluate($filepath);
    if ($@) {
        Carp::croak sprintf "failed to load fixture file %s", $filepath;
    }

    try {
        Ocean::Config::Loader->validate_config($fixtures,
            Ocean::Standalone::Fixture::Schema::Default->config);
    } catch {
        $self->log_crit("Invalid Fixture: %s", $_); 
        $self->log_debug("Fixture: %s", ddf($fixtures));
        Carp::croak "Invalid Fixture: validation failed";
    };

    $fixtures = Ocean::Config::Loader->substitute_config($fixtures);
    return $fixtures;
}

sub _setup_database {
    my ($self, $fixtures) = @_;

    my $user_fixtures = $fixtures->{users};

    my $tmp_users = {};

    for my $user_fixture ( @$user_fixtures ) {
        my $user_fixture_key = delete $user_fixture->{id};
        Carp::croak q(Invalid Fixture: 'id' not found)
            unless defined $user_fixture_key;

        $tmp_users->{$user_fixture_key} = 
            $self->add_user(%$user_fixture);
    }

    my $relation_fixtures = $fixtures->{relations} || [];

    for my $relation_fixture ( @$relation_fixtures ) {

        my $follower_key = $relation_fixture->{follower};
        my $follower = $tmp_users->{ $follower_key } 
            or Carp::croak "Setting Relation: User not found for key, '%s'", $follower_key;

        my $followee_key = $relation_fixture->{followee};
        my $followee = $tmp_users->{ $followee_key }
            or Carp::croak "Setting Relation: User not found for key, '%s'", $followee_key;

        $self->get('db')->insert_relation(
            follower => $follower, 
            followee => $followee,
        );
    }
}

sub add_user {
    my ($self, %args) = @_;

    my $image_url = $args{profile_img_url};

    if ($image_url) {
        my $img = Ocean::Util::Image::get_image_data_of_url($image_url);
        $args{profile_img_b64}  = $img->{b64};
        $args{profile_img_hash} = $img->{hash};
    } else {
        my $img_filepath = delete $args{profile_img_file};
        if ($img_filepath) {
            my $img = Ocean::Util::Image::get_image_data_of_file($img_filepath);
            $args{profile_img_b64}  = $img->{b64};
            $args{profile_img_hash} = $img->{hash};
        }
    }

    my $user = $self->get('db')->insert_user(%args);

    if ($args{is_echo}) {

        my $resource = sha1_hex( gen_random(32) );

        $self->get('db')->insert_connection(
            user_id         => $user->user_id,
            username        => $user->username,
            resource        => $resource,
            presence_show   => 'chat',
            presence_status => 'hoge',
        );
    }
    return $user;
}

sub follow {
    my ($self, %args) = @_;
    $self->get('db')->insert_relation(
        follower => $args{from},
        followee => $args{to},
    );
}

sub worker_finalize {
    my $self = shift;
}

sub service_finalize {
    my $self = shift;
    my $db_manager = $self->_create_db_manager();
    $db_manager->clear();
}

1;
