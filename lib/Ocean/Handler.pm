package Ocean::Handler;

use strict;
use warnings;

use Ocean::Config;

use Log::Minimal;
use Try::Tiny;

sub new {
    my $class = shift;
    my $self = bless {
        _delegate => undef, 
    }, $class;
    return $self;
}

sub config {
    my ($self, $field) = @_;
    return Ocean::Config->instance->get(handler => $field);
}

sub host {
    my $self = shift;
    $self->_server_config('host');
}

sub port {
    my $self = shift;
    $self->_server_config('port');
}

sub domain {
    my $self = shift;
    $self->_server_config('domain');
}

sub _server_config {
    my ($self, $field) = @_;
    return Ocean::Config->instance->get(server => $field);
}

sub log_debug { 
    my $self     = shift;
    my $template = shift;
    debugf('<Handler> ' . $template, @_);
}

sub log_info { 
    my $self     = shift;
    my $template = shift;
    infof('<Handler> ' . $template, @_);
}

sub log_warn { 
    my $self     = shift;
    my $template = shift;
    warnf('<Handler> ' . $template, @_);
}

sub log_crit { 
    my $self     = shift;
    my $template = shift;
    critff('<Handler> ' . $template, @_);
}

sub set_delegate {
    my ($self, $delegate) = @_;
    $self->{_delegate} = $delegate;
}

sub release {
    my $self = shift;
    delete $self->{_delegate};
}

sub event_method_map { +{ } }

sub dispatch {
    my ($self, $event_type, $ctx, $args, $rethrow) = @_;

    my $method = $self->event_method_map->{$event_type};
    unless ($method) {
        $self->log_warn('Unsupported event type: %s', $event_type);
        return;
    }
    try {
        $self->$method($ctx, $args);
    } catch {
        $self->log_crit('Caught an exception at %s: %s', $event_type, $_);
        die $_ if $rethrow;
    };
}

sub deliver {
    my ($self, $req) = @_; 
    $self->{_delegate}->deliver($req);
}

1;
