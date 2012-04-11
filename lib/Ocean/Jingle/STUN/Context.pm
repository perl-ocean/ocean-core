package Ocean::Jingle::STUN::Context;

use strict;
use warnings;

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

sub initialize {
    my $self = shift;
    # template method
}

sub finalize {
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

sub respond {
    my ($self, $sender, $bytes) = @_;
    $self->{_delegate}->deliver_message($sender, $bytes);
}

1;
