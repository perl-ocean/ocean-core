package Ocean::Cluster::Frontend::Handler::Connection;

use strict;
use warnings;

use parent 'Ocean::Handler::Connection';

use Ocean::Constants::EventType;

sub on_bind_request {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::BIND_REQUEST, 
        {
            stream_id   => $args->stream_id, 
            user_id     => $args->user_id,
            resource    => $args->resource || '',
            want_extval => $args->want_extval,
        }
    );
}

sub on_silent_disconnection {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::SILENT_DISCONNECTION, 
        {
            from => $args->from->as_string,
        }
    );
}

sub on_presence {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::BROADCAST_PRESENCE, 
        {
            from   => $args->from->as_string,     
            status => $args->status,
            show   => $args->show,
        }
    );
}

sub on_initial_presence {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::BROADCAST_INITIAL_PRESENCE, 
        {
            from     => $args->from->as_string,     
            no_probe => $args->no_probe,
            status   => $args->status,
            show     => $args->show,
        }
    );
}

sub on_unavailable_presence {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::BROADCAST_UNAVAILABLE_PRESENCE, 
        {
            from => $args->from->as_string,
        }
    );
}

1;
