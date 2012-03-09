package Ocean::Standalone::Cluster::Backend::Handler::P2P;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::Handler::P2P';
use Ocean::Stanza::DeliveryRequestBuilder::TowardUserIQ;

sub on_toward_user_iq {
    my ($self, $ctx, $node_id, $args) = @_;

    my $sender_jid   = $args->from;
    my $receiver_jid = $args->to;

    # XXX check relation?
    my $receiver = 
        $ctx->get('db')->find_user_by_username($receiver_jid->node);
    return unless $receiver;

    unless ($receiver->is_echo) {

        my $conn = 
            $ctx->get('db')->find_available_connection_by_jid($receiver_jid);
        return unless $conn;

        my $builder = 
            Ocean::Stanza::DeliveryRequestBuilder::TowardUserIQ->new;

        $builder->to($sender_jid);
        $builder->from($receiver_jid);
        $builder->query_type($args->type);
        $builder->request_id($args->id);
        $builder->raw($args->raw);

        $ctx->deliver($conn->node_id, $builder->build());
    }
}

1;
