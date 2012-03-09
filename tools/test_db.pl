#!/usr/bin/perl
use strict;
use warnings;

use Ocean::DataStore::DB::FileManager;
use Ocean::DataStore::DB::Handler;
use FindBin;
use File::Spec;
use Data::Dump qw(dump);
use feature 'say';
use feature 'switch';

sub main {

    my $filepath = File::Spec->catfile($FindBin::RealBin, qw(.. t data database test01.db));

    given($ARGV[0]) {
        when('setup') { &setup($filepath) }
        when('clear') { &clear($filepath) }
        default       { &show($filepath)  }
    }
}

sub show {
    my $filepath = shift;

    my $handler = Ocean::DataStore::DB::Handler->new(
        file => $filepath, 
    );

    $handler->initialize();

    my $user_iter = $handler->{_db}->search('user', {}, { order_by => 'id' });
    while (my $user_row = $user_iter->next) {
        say dump($user_row->get_columns()); 
    }

    my $rel_iter = $handler->{_db}->search('relation', {}, { order_by => 'id' });
    while (my $rel_row = $rel_iter->next) {
        say dump($rel_row->get_columns()); 
    }

}

sub clear {
    my $filepath = shift;

    my $manager = Ocean::DataStore::DB::FileManager->new(
        file => $filepath, 
    );

    $manager->clear();
}

sub setup {
    my $filepath = shift;

    my $manager = Ocean::DataStore::DB::FileManager->new(
        file => $filepath, 
    );

    $manager->setup();

    my $handler = Ocean::DataStore::DB::Handler->new(
        file => $filepath, 
    );

    $handler->initialize();

    $handler->insert_user(
        username => q{taro}, 
        nickname => q{Taro},
        password => q{foobar},
    );
    $handler->insert_user(
        username => q{jiro}, 
        nickname => q{Jiro},
        password => q{foobar},
    );
}

&main();

__END__

=head1 NAME

test_db.pl - test db manager

=head1 SYNOPSIS

    perl test_db.pl setup   
    perl test_db.pl clear
    perl test_db.pl show

=cut

