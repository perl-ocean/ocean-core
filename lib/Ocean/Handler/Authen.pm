package Ocean::Handler::Authen;

use strict;
use warnings;

use parent 'Ocean::Handler';
use Ocean::Error;
use Ocean::Constants::EventType;

use Log::Minimal;

sub log_debug {
    my $self     = shift;
    my $template = shift;
    debugf('<Handler::Authen> ' . $template, @_);
}

sub log_info {
    my $self     = shift;
    my $template = shift;
    infof('<Handler::Authen> ' . $template, @_);
}

sub log_warn {
    my $self     = shift;
    my $template = shift;
    warnf('<Handler::Authen> ' . $template, @_);
}

sub log_crit {
    my $self     = shift;
    my $template = shift;
    critf('<Handler::Authen> ' . $template, @_);
}

sub event_method_map { +{
    Ocean::Constants::EventType::TOO_MANY_AUTH_ATTEMPT, 
        'on_too_many_auth_attempt',
    Ocean::Constants::EventType::SASL_AUTH_REQUEST, 
        'on_sasl_auth_request',
    Ocean::Constants::EventType::SASL_PASSWORD_REQUEST, 
        'on_sasl_password_request',
    Ocean::Constants::EventType::SASL_SUCCESS_NOTIFICATION, 
        'on_sasl_success_notification',
    Ocean::Constants::EventType::HTTP_AUTH_REQUEST, 
        'on_http_auth_request',
} }

sub on_too_many_auth_attempt {
    my ($self, $ctx, $args) = @_;
    $self->log_warn("on_too_many_auth_attempt not implemented");
}

sub on_sasl_auth_request {
    my ($self, $ctx, $args) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Handler::Authn::on_sasl_auth_request}, 
    );
}

sub on_sasl_password_request {
    my ($self, $ctx, $args) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Handler::Authen::on_sasl_auth_request}, 
    );
}

sub on_sasl_success_notification {
    my ($self, $ctx, $args) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Handler::Authen::on_sasl_auth_request}, 
    );
}

sub on_http_auth_request {
    my ($self, $ctx, $args) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Handler::Authen::on_http_auth_request}, 
    );
}

1;
