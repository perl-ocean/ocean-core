package Ocean::Standalone::Handler::P2P;

use strict;
use warnings;

use parent 'Ocean::Handler::P2P';
use Ocean::Stanza::DeliveryRequestBuilder::TowardUserIQ;

sub on_toward_user_iq {
    my ($self, $ctx, $args) = @_;

    my $sender_jid   = $args->from;
    my $receiver_jid = $args->to;

    # XXX check relation?
    my $receiver = 
        $ctx->get('db')->find_user_by_username($receiver_jid->node);
    return unless $receiver;

    unless ($receiver->is_echo) {

        my $builder = 
            Ocean::Stanza::DeliveryRequestBuilder::TowardUserIQ->new;
        $builder->to($receiver_jid);
        $builder->from($sender_jid);
        $builder->query_type($args->type);
        $builder->request_id($args->id);
        $builder->raw($args->raw);
        $ctx->deliver($builder->build());
    }
}

sub on_jingle_info_request {
    my ($self, $ctx, $args) = @_;

    my $request_id = $args->id;
    my $sender_jid = $args->from;

    # my $builder = Ocean::Stanza::DeliveryRequestBuilder::JingleInfo->new;
    # $builder->to($sender_jid);
    # $builder->from(Ocean::Config->instance->get(server => q{domain}));
    # $builder->token();
    # $ctx->deliver($builder->build());
}

1;
