package Ocean::Standalone::DB::Handler;

use strict;
use warnings;

use Ocean::Standalone::DB;
use Carp ();
use Log::Minimal;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _file              => $args{file},
        _relation_id_pod   => 0,
        _user_id_pod       => 0,
        _connection_id_pod => 0,
        _db                => undef, 
    }, $class;
    return $self;
}

sub initialize {
    my $self = shift;

    die "DB file is not exists or can't be read" 
        unless ($self->{_file} && -e $self->{_file} && -f _);

    $self->{_db} = 
        $self->_create_connection( $self->{_file} );

}

sub load_fixture {
    my ($self, $filepath) = @_;

    unless (-e $filepath) {
        Carp::croak sprintf "fixture file '%s' not found", $filepath;
    }

    my $fixtures = eval { require $filepath };
    if ($@) {
        Carp::croak sprintf "failed to load fixture file %s", $filepath;
    }

    my $user_fixtures = $fixtures->{users};

    my $tmp_users = {};

    for my $user_fixture_key ( sort keys %$user_fixtures ) {
        # XXX should validate user's params
        $tmp_users->{$user_fixture_key} = 
            $self->insert_user(%{ $user_fixtures->{$user_fixture_key} });
    }

    my $relation_fixtures = $fixtures->{relations} || [];

    for my $relation_fixture ( @$relation_fixtures ) {

        my $follower_key = $relation_fixture->{follower};
        my $follower = $tmp_users->{ $follower_key } 
            or Carp::croak "Setting Relation: User not found for key, '%s'", $follower_key;

        my $followee_key = $relation_fixture->{followee};
        my $followee = $tmp_users->{ $followee_key }
            or Carp::croak "Setting Relation: User not found for key, '%s'", $followee_key;

        $self->insert_relation(
            follower => $follower, 
            followee => $followee,
        );
    }
}

sub _create_connection {
    my ($self, $file) = @_;
    my $db = Ocean::Standalone::DB->new({
        connect_info => [
            sprintf("dbi:SQLite:dbname=%s", $file), 
            "", 
            "",
            {
                AutoCommit => 1, 
                RaiseError => 1,
            },
        ],
    });
    return $db;
}

sub insert_relation {
    my ($self, %args) = @_;

    my $id = $self->{_relation_id_pod}++;

    my %params = (
        id          => $id,
        followee_id => $args{followee}->id,
        follower_id => $args{follower}->id,
    );

    debugf("<DB> insert relation: %s", ddf(\%params));

    $self->{_db}->insert( relation => {%params} );
}

sub insert_user {
    my ($self, %args) = @_;

    $args{id} = $self->{_user_id_pod}++;

    debugf("<DB> insert user, %s", ddf(\%args));

    $self->{_db}->insert( user => {%args} );
}

sub update_user {
    my ($self, $user) = @_;
    $user->update();
}

sub find_user_by_id {
    my ($self, $user_id) = @_;
    return $self->{_db}->single( user => { 
        id => $user_id 
    } );
}

sub find_user_by_username {
    my ($self, $username) = @_;
    return $self->{_db}->single( user => {
        username => $username,     
    } );
    # TODO check process when not exists
}

sub find_user_by_cookie {
    my ($self, $cookie) = @_;
    return $self->{_db}->single( user => {
        cookie => $cookie, 
    } );
    # TODO check process when not exists
}

sub insert_node {
    my ($self, %args) = @_;

    my %params = (
        node_id    => $args{node_id}, 
        node_host  => $args{node_host},
        node_port  => $args{node_port},
        inbox_host => $args{inbox_host},
        inbox_port => $args{inbox_port},
        created_at => $args{created_at},
        updated_at => $args{updated_at},
    );

    # TODO check if the node_id is not exists
    $self->{_db}->insert( node => {%params} );
}

sub update_node {
    my ($self, $node_id, %args) = @_;
    my $node = $self->find_node_by_id($node_id);
    return unless $node;
    $node->total_connection_counter( $args{total_connection_counter} );
    $node->current_connection_counter( $args{current_connection_counter} );
    $node->update();
}

sub find_node_by_id {
    my ($self, $node_id) = @_;
    return $self->{_db}->single( node => {
        node_id => $node_id, 
    } );
}

sub insert_connection {
    my ($self, %args) = @_;

    $args{id} = $self->{_connection_id_pod}++;

    my %params = (
        user_id  => $args{user_id},
        username => $args{username},
        resource => $args{resource},
    );

    for my $key ( qw(node_id presence_show presence_status) ) {
        $params{$key} = $args{$key} if $args{$key};
    }

    debugf("<DB> insert connection, %s", ddf(\%params));

    $self->{_db}->insert( connection => {%params} ); 
}

sub update_connection {
    my ($self, $conn) = @_;
    $conn->update();
}

sub remove_connection {
    my ($self, $conn) = @_;
    $conn->delete();
}

sub find_available_connection_by_jid {
    my ($self, $jid) = @_;
    my $conn = $self->find_connection_by_jid($jid);
    return ($conn && $conn->presence_show) ? $conn : undef;
}

sub find_connection_by_id {
    my ($self, $id) = @_;
    return $self->{_db}->single( connection => {
        id => $id,
    });
}

sub find_connection_by_jid {
    my ($self, $jid) = @_;

    my $username = $jid->node;
    my $resource = $jid->resource;

    return $self->{_db}->single( connection => {
        username => $username,
        resource => $resource,
    });
}

sub search_connection_by_username {
    my ($self, $username) = @_;
    return $self->{_db}->search( connection => {
        username => $username,     
    })->all;
}

sub search_available_connection_by_username {
    my ($self, $username) = @_;
    my @conns = $self->search_connection_by_username($username);
    @conns = grep { $_->presence_show } @conns;
    return @conns;
}

sub search_connection_by_user_id {
    my ($self, $user_id) = @_;
    return $self->{_db}->search( connection => {
        user_id => $user_id,     
    } )->all;
}

sub search_available_connection_by_user_id {
    my ($self, $user_id) = @_;
    my @conns = $self->search_connection_by_user_id($user_id);
    @conns = grep { $_->presence_show } @conns;
    return @conns;
}

sub search_followers_of {
    my ($self, $followee) = @_;
    my $iterator = $self->{_db}->search( relation => {
        followee_id => $followee->id,   
    } );
    my @followers = map { $_->follower_id } $iterator->all;
    return @followers;
}

sub search_followees_of {
    my ($self, $follower) = @_;
    my $iterator = $self->{_db}->search( relation => {
        follower_id => $follower->id,     
    } );
    my @followees = map { $_->followee_id } $iterator->all;
    return @followees;
}

sub find_room_by_id {
    my ($self, $id) = @_;
    return $self->{_db}->single(room => {
        id => $id,     
    });
}

sub find_room_by_name {
    my ($self, $name) = @_;
    return $self->{_db}->single(room => {
        name => $name,     
    });
}

sub insert_room {
    my ($self, %args) = @_;
    # TODO validate args
    # $args{name};
    return $self->{_db}->insert(room => {
        name => $args{name},     
    });
}

sub insert_room_member {
    my ($self, %args) = @_;
    # TODO validate args
    # $args{room_id};
    # $args{username};
    return $self->{_db}->insert(room_member => {
        room_id  => $args{room_id},
        username => $args{username},
    });
}

sub insert_room_member_connection {
    my ($self, %args) = @_;
    # TODO validate args
    # $args{room_id};
    # $args{nickname};
    # $args{connection_id};
    return $self->{_db}->insert(room_member_connection => {
        room_id       => $args{room_id},
        nickname      => $args{nickname},
        connection_id => $args{connection_id},
    });
}

sub find_room_member_by_room_id_and_username {
    my ($self, $room_id, $username) = @_;
    return $self->{_db}->single(room_member => {
        room_id  => $room_id,
        username => $username,
    });
}

sub search_belonging_rooms_by_username {
    my ($self, $username) = @_;
    my @list = $self->{_db}->search(room_member => {
        username => $username,     
    })->all;
    return map { $self->find_room_by_id($_->room_id) } @list;
}

sub search_room_member_connection_by_room_id {
    my ($self, $room_id) = @_;
    return $self->{_db}->search(room_member_connection => {
        room_id => $room_id     
    })->all;
}

sub find_room_member_connection_by_room_id_and_connection_id {
    my ($self, $room_id, $connection_id) = @_;
    return $self->{_db}->single(room_member_connection => {
        room_id       => $room_id,
        connection_id => $connection_id,
    });
}

sub find_room_member_connection_by_room_id_and_nickname {
    my ($self, $room_id, $nickname) = @_;
    return $self->{_db}->single(room_member_connection => {
        room_id  => $room_id,
        nickname => $nickname,
    });
}

sub _disconnect {
    my $self = shift;
    $self->{_db}->disconnect();
}

sub finalize {
    my $self = shift;
    $self->_disconnect();
}

1;
