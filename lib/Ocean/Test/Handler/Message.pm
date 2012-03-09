package Ocean::Test::Handler::Message;

use strict;
use warnings;

use parent 'Ocean::Standalone::Handler::Message';
use Ocean::Stanza::DeliveryRequestBuilder::ChatMessage;

sub emulate_deliver_message {
    my ($self, $ctx, $sender_jid, $receiver_jid, $body, $thread) = @_;

    my $builder = 
        Ocean::Stanza::DeliveryRequestBuilder::ChatMessage->new;
    $builder->to($receiver_jid);
    $builder->from($sender_jid);
    $builder->body($body);
    $builder->thread($thread || '');

    $ctx->deliver($builder->build());
}

1;
