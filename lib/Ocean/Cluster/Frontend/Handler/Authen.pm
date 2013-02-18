package Ocean::Cluster::Frontend::Handler::Authen;

use strict;
use warnings;

use parent 'Ocean::Handler::Authen';

use Ocean::Constants::EventType;

sub on_too_many_auth_attempt {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::TOO_MANY_AUTH_ATTEMPT, 
        {
            host => $args->host,
            port => $args->port,
        }
    );
}

sub on_sasl_auth_request {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::SASL_AUTH_REQUEST, 
        {
            stream_id => $args->stream_id, 
            domain    => $args->domain,
            mechanism => $args->mechanism,
            text      => $args->text,
        }
    );
}

sub on_sasl_password_request {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::SASL_PASSWORD_REQUEST, 
        {
            stream_id => $args->stream_id, 
            username  => $args->username,
        }
    );
}

sub on_sasl_success_notification {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::SASL_SUCCESS_NOTIFICATION, 
        {
            stream_id => $args->stream_id, 
            username  => $args->username,
        }
    );
}

sub on_http_auth_request {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::HTTP_AUTH_REQUEST, 
        {
            stream_id    => $args->stream_id,
            cookie       => $args->cookie,
            domain       => $args->domain,
            origin       => $args->origin,
            query_params => $args->query_params,
        }
    );
}

1;
