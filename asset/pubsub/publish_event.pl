#!/usr/bin/perl
use strict;
use warnings;

use Gearman::Client;

use Ocean::Constants::Cluster;
use Ocean::Constants::EventType;

use Ocean::Cluster::EventPublisher::Default;
use Ocean::Stanza::Outgoing::PubSub::Event;
use Ocean::Stanza::Outgoing::PubSub::Event::Item;

my @SERVER_ADDRESSES = (
    '192.168.0.1:5111',
    '192.168.0.2:5111',
);

sub main {

    my $publisher = Ocean::Cluster::EventPublisher::Default->new(
        job_servers => \@SERVER_ADDRESSES, 
    );

    my $event = Ocean::Stanza::Outgoing::PubSub::Event->new(
        node => 'activity', 
        from => q{pubsub.xmpp.mixi.jp},
        to   => q{user_id@xmpp.mixi.jp},
    );

    $event->add_item( Ocean::Stanza::Outgoing::PubSub::Event::Item->new(
        id        => q{xxx01},     
        name      => q{voice},
        namespace => q{http://mixi.jp/ns#voice},
        fields    => {
            member_id => q{},
            summary   => q{},
            timestamp => q{}, 
            src       => q{},
        },
    ) );
    $event->add_item( Ocean::Stanza::Outgoing::PubSub::Event::Item->new(
        id        => q{xxx02},
        name      => q{photo},
        namespace => q{http://mixi.jp/ns#photo},
        fields    => {
            member_id => q{},
            summary   => q{},
            timestamp => q{}, 
            src       => q{},
        },
    ) );

    $publisher->publish_event($event);
}

__END__

