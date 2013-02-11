package Ocean::Cluster::Frontend::Handler::PubSub;

use strict;
use warnings;

use parent 'Ocean::Handler::PubSub';

use Ocean::Constants::EventType;

sub on_pubsub_event {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::PUBLISH_EVENT,
        {
            from   => $args->from,
            to     => $args->to->as_string,
            node   => $args->node,
            items  => $args->items,
        }
    );
}

1;
