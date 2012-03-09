package Ocean::Cluster::Backend::Context;

use strict;
use warnings;

use Ocean::Config;

use Log::Minimal;
use Try::Tiny;

sub new {
    my $class = shift;
    my $self = bless {
        _stash    => {}, 
        _delegate => undef,
    }, $class;
    return $self;
}

sub config {
    my ($self, $field) = @_;
    return Ocean::Config->instance->get(handler => $field);
}

sub log_debug { 
    my $self     = shift;
    my $template = shift;
    debugf('<Server> <Context> ' . $template, @_);
}

sub log_info { 
    my $self     = shift;
    my $template = shift;
    infof('<Server> <Context> ' . $template, @_);
}

sub log_warn { 
    my $self     = shift;
    my $template = shift;
    warnf('<Server> <Context> ' . $template, @_);
}

sub log_crit { 
    my $self     = shift;
    my $template = shift;
    critff('<Server> <Context> ' . $template, @_);
}

sub set_delegate {
    my ($self, $delegate) = @_;
    $self->{_delegate} = $delegate;
}

sub service_initialize {
    my $self = shift;
    # template method
}

sub service_finalize {
    my $self = shift;
    # template method
}

sub worker_initialize {
    my $self = shift;
    # template method
}

sub worker_finalize {
    my $self = shift;
    # template method
}

sub release {
    my $self = shift;
    delete $self->{_delegate}
        if $self->{_delegate};
}

sub set {
    my ($self, $key, $value) = @_;
    $self->{_stash}{$key} = $value;
}

sub get {
    my ($self, $key) = @_;
    return $self->{_stash}{$key};
}

sub deliver {
    my ($self, $node_id, $req) = @_;
    $self->{_delegate}->on_delivery_request($node_id, $req);
}

1;
