#!/usr/bin/env perl
use strict;
use warnings;

use Gearman::Client;

use Ocean::Constants::Cluster;
use Ocean::Constants::EventType;

use Ocean::Cluster::EventPublisher::Default;
use Ocean::Stanza::DeliveryRequestBuilder::PubSubEvent;
use Ocean::Stanza::DeliveryRequestBuilder::PubSubEventItem;

my @SERVER_ADDRESSES = (
    '127.0.0.1:7001',
);

sub main {

    my $publisher = Ocean::Cluster::EventPublisher::Default->new(
        job_servers => \@SERVER_ADDRESSES,
        queue_name => "ocean_default",
    );

    my $event = Ocean::Stanza::DeliveryRequestBuilder::PubSubEvent->new;
    $event->node('activity');
    $event->from(q{pubsub.xmpp.mixi.jp});
    $event->to(q{czzgs373yqh6d@dvm211.lo.mixi.jp});

    my $item1 = Ocean::Stanza::DeliveryRequestBuilder::PubSubEventItem->new;
    $item1->id(q{xxx01});
    $item1->name(q{voice});
    $item1->namespace(q{http://mixi.jp/ns#voice});
    $item1->add_field('member_id', q{});
    $item1->add_field('summary', q{});
    $item1->add_field('timestamp', q{});
    $item1->add_field('src', q{});
    $event->add_item_builder($item1);

    my $item2 = Ocean::Stanza::DeliveryRequestBuilder::PubSubEventItem->new;
    $item2->id(q{xxx02});
    $item2->name(q{photo});
    $item2->namespace(q{http://mixi.jp/ns#photo});
    $item2->add_field('member_id', q{});
    $item2->add_field('summary', q{});
    $item2->add_field('timestamp', q{});
    $item2->add_field('src', q{});
    $event->add_item_builder($item2);

    $publisher->publish_event($event->build());
    print "published\n";
}

main;

__END__

