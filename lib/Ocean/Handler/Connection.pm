package Ocean::Handler::Connection;

use strict;
use warnings;

use parent 'Ocean::Handler';
use Ocean::Error;
use Ocean::Constants::EventType;

use Log::Minimal;

sub log_debug {
    my $self     = shift;
    my $template = shift;
    debugf('<Handler::Connection> ' . $template, @_);
}

sub log_info {
    my $self     = shift;
    my $template = shift;
    infof('<Handler::Connection> ' . $template, @_);
}

sub log_warn {
    my $self     = shift;
    my $template = shift;
    warnf('<Handler::Connection> ' . $template, @_);
}

sub log_crit {
    my $self     = shift;
    my $template = shift;
    critf('<Handler::Connection> ' . $template, @_);
}

sub event_method_map { +{
    Ocean::Constants::EventType::BIND_REQUEST, 
        'on_bind_request',
    Ocean::Constants::EventType::BROADCAST_PRESENCE, 
        'on_presence',
    Ocean::Constants::EventType::BROADCAST_INITIAL_PRESENCE, 
        'on_initial_presence',
    Ocean::Constants::EventType::BROADCAST_UNAVAILABLE_PRESENCE, 
        'on_unavailable_presence',
    Ocean::Constants::EventType::SILENT_DISCONNECTION, 
        'on_silent_disconnection',
} }

sub on_bind_request {
    my ($self, $ctx, $args) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Handler::Connection::on_bind_request}, 
    );
}

sub on_presence {
    my ($self, $ctx, $args) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Handler::Connection::on_presence}, 
    );
}

sub on_initial_presence {
    my ($self, $ctx, $args) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Handler::Connection::on_initial_presence}, 
    );
}

sub on_unavailable_presence {
    my ($self, $ctx, $args) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Handler::Connection::on_unavailable_presence}, 
    );
}

sub on_silent_disconnection {
    my ($self, $ctx, $args) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Handler::Connection::on_silent_disconnection}, 
    );
}

1;
