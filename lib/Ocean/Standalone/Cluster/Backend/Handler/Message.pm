package Ocean::Standalone::Cluster::Backend::Handler::Message;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::Handler::Message';

use Ocean::Stanza::DeliveryRequestBuilder::ChatMessage;

sub on_message {
    my ($self, $ctx, $node_id, $args) = @_;

    my $sender_jid   = $args->from;
    my $receiver_jid = $args->to;

    # XXX check if sender and receiver are in the same domain

    # XXX check relation?
    my $receiver = 
        $ctx->get('db')->find_user_by_username($receiver_jid->node);
    return unless $receiver;

    if ($receiver->is_echo) {

        my $builder = 
            Ocean::Stanza::DeliveryRequestBuilder::ChatMessage->new;
        $builder->to($sender_jid);
        $builder->from($receiver_jid);
        $builder->body($args->body);
        $builder->html($args->html);
        $builder->thread($args->thread || '');

        $ctx->deliver($node_id, $builder->build());

    } else {

        my @conns = $ctx->get('db')->search_available_connection_by_username( 
            $receiver_jid->node, $receiver_jid->domain );

        for my $conn ( @conns ) {

            my $builder = 
                Ocean::Stanza::DeliveryRequestBuilder::ChatMessage->new;

            my $to_jid = Ocean::JID->build(
                $conn->username,
                $conn->domain,
                $conn->resource,
            );

            $builder->to($to_jid);
            $builder->from($sender_jid);
            $builder->body($args->body);
            $builder->thread($args->thread);
            $builder->state($args->state);

            $ctx->deliver($conn->node_id, $builder->build());

        }
    }
}

1;
