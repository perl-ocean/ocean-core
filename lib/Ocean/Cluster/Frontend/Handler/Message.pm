package Ocean::Cluster::Frontend::Handler::Message;

use strict;
use warnings;

use parent 'Ocean::Handler::Message';

use Ocean::Constants::EventType;

sub on_message {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::SEND_MESSAGE, 
        {
            from   => $args->from->as_string,     
            to     => $args->to->as_string,
            #type   => $message->type,
            thread => $args->thread,
            body   => $args->body,
            state  => $args->state,
        }
    );
}

1;
