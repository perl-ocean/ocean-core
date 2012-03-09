use strict;
use warnings;

use Test::More;

use Ocean::Cluster::EventPublisher;
use Ocean::Cluster::Serializer::JSON;
use Ocean::Cluster::EventPublisher::Dispatcher::Spy;

use Ocean::Stanza::DeliveryRequestBuilder::PubSubEvent;
use Ocean::Stanza::DeliveryRequestBuilder::PubSubEventItem;

my $dispatcher = Ocean::Cluster::EventPublisher::Dispatcher::Spy->new;
my $publisher = Ocean::Cluster::EventPublisher->new(
    serializer => Ocean::Cluster::Serializer::JSON->new,
    dispatcher => $dispatcher,
);

my $event = Ocean::Stanza::DeliveryRequestBuilder::PubSubEvent->new({
    node => q{activity},
    from => q{pubsub.xmpp.example.org},
    to   => q{taro@xmpp.example.org},
});

my $items = [
    {
        id        => q{activity_photo_01},
        name      => q{photo},
        namespace => q{http://example.org/ns#photo},
        fields    => {
            user_id   => q{0001}, 
            src       => q{http://example.org/0001/photo/0001.html},
            timestamp => q{2011/01/01 11:11:11},
        },
    },
    {
        id        => q{activity_video_01},
        name      => q{video},
        namespace => q{http://example.org/ns#video},
        fields    => {
            user_id   => q{0001}, 
            src       => q{http://example.org/0001/video/0001.html},
            timestamp => q{2011/01/01 12:12:12},
        },
    },
];

my $builder = 
    Ocean::Stanza::DeliveryRequestBuilder::PubSubEvent->new;
$builder->node(q{activity});
$builder->from(q{pubsub.xmpp.example.org});
$builder->to(q{taro@xmpp.example.org});

for my $item ( @$items ) {
    my $item_builder = 
        Ocean::Stanza::DeliveryRequestBuilder::PubSubEventItem->new;
    $item_builder->id( $item->{id} );
    $item_builder->name( $item->{name} );
    $item_builder->namespace( $item->{namespace} );
    for my $key ( keys %{ $item->{fields} } ) {
        $item_builder->add_field( $key, $item->{fields}{$key} );
    }
    $builder->add_item_builder( $item_builder );
}


$publisher->publish_event($builder->build());

my $result = $dispatcher->get_result_at(0);
is($result, q|{"node_id":"__ANON__","args":{"to":"taro@xmpp.example.org","from":"pubsub.xmpp.example.org","node":"activity","items":[{"fields":{"timestamp":"2011/01/01 11:11:11","src":"http://example.org/0001/photo/0001.html","user_id":"0001"},"namespace":"http://example.org/ns#photo","name":"photo","id":"activity_photo_01"},{"fields":{"timestamp":"2011/01/01 12:12:12","src":"http://example.org/0001/video/0001.html","user_id":"0001"},"namespace":"http://example.org/ns#video","name":"video","id":"activity_video_01"}]},"type":"publish_pubsub_event"}|);

done_testing();
