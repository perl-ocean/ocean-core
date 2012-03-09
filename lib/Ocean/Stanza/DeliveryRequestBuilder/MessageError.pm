package Ocean::Stanza::DeliveryRequestBuilder::MessageError;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::DELIVER_MESSAGE_ERROR }

sub to {
    my ($self, $to_jid) = @_;
    $self->{_to} = "$to_jid";
    return $self;
}

sub from {
    my ($self, $from_jid) = @_;
    $self->{_from} = "$from_jid";
    return $self;
}

sub body {
    my ($self, $body) = @_;
    $self->{_body} = $body;
    return $self;
}

sub subject {
    my ($self, $subject) = @_;
    $self->{_subject} = $subject;
    return $self;
}

sub thread {
    my ($self, $thread) = @_;
    $self->{_thread} = $thread;
    return $self;
}

sub state {
    my ($self, $state) = @_;
    $self->{_state} = $state;
    return $self;
}

sub error_type {
    my ($self, $error_type) = @_;
    $self->{_error_type} = $error_type;
    return $self;
}

sub error_reason {
    my ($self, $error_reason) = @_;
    $self->{_error_reason} = $error_reason;
    return $self;
}

sub error_text {
    my ($self, $error_text) = @_;
    $self->{_error_text} = $error_text;
    return $self;
}

sub build_args {
    my $self = shift;

    my $args = {};

    Ocean::Error::ParamNotFound->throw(
        message => q{'to' not found}, 
    ) unless exists $self->{_to};

    $args->{to} = $self->{_to};

    Ocean::Error::ParamNotFound->throw(
        message => q{'from' not found}, 
    ) unless exists $self->{_from};

    $args->{from}   = $self->{_from};

    Ocean::Error::ParamNotFound->throw(
        message => q{'error_type' not found}, 
    ) unless exists $self->{_error_type};

    $args->{error_type} = $self->{_error_type};

    Ocean::Error::ParamNotFound->throw(
        message => q{'error_reason' not found}, 
    ) unless exists $self->{_error_reason};

    $args->{error_reason} = $self->{_error_reason};

    $args->{body}       = $self->{_body}       || '';
    $args->{subject}    = $self->{_subject}    || '';
    $args->{thread}     = $self->{_thread}     || '';
    $args->{state}      = $self->{_state}      || '';
    $args->{error_text} = $self->{_error_text} || '';

    return $args;
}

1;
