package Ocean::Standalone::Cluster::Backend::Handler::PubSub;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::Handler::PubSub';
use Ocean::JID;
use Ocean::Stanza::DeliveryRequestBuilder::PubSubEvent;
use Ocean::Stanza::DeliveryRequestBuilder::PubSubEventItem;

sub on_pubsub_event {
    my ($self, $ctx, $node_id, $args) = @_;

    my $sender_jid   = Ocean::JID->new($args->from);
    my $receiver_jid = Ocean::JID->new($args->to);
    my $node         = $args->node;
    my $items        = $args->items || [];

    my @conns = $ctx->get('db')->search_connection_by_username( 
        $receiver_jid->node, $receiver_jid->domain );

    for my $conn ( @conns ) {
        my $builder = 
            Ocean::Stanza::DeliveryRequestBuilder::PubSubEvent->new;
        my $to_jid = Ocean::JID->build(
            $conn->username,
            $conn->domain,
            $conn->resource,
        );
        $builder->from($sender_jid);
        $builder->to($to_jid);
        $builder->node($node);
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
        $ctx->deliver($conn->node_id, $builder->build());
    }
}

1;
