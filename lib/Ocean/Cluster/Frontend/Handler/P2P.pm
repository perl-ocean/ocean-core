package Ocean::Cluster::Frontend::Handler::P2P;

use strict;
use warnings;

use parent 'Ocean::Handler::P2P';

use Ocean::Constants::EventType;

sub on_toward_user_iq {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::SEND_IQ_TOWARD_USER, 
        {
            from   => $args->from->as_string,     
            to     => $args->to->as_string,
            id     => $args->id,
            type   => $args->type,
            raw    => $args->raw,
        }
    );
}


1;
