package Ocean::Stanza::DeliveryRequestBuilder::PresenceError;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::DELIVER_PRESENCE_ERROR }

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

sub show {
    my ($self, $show) = @_;
    $self->{_show} = $show;
    return $self;
}

sub status {
    my ($self, $status) = @_;
    $self->{_status} = $status;
    return $self;
}

sub is_for_room {
    my ($self, $is_for_room) = @_;
    $self->{_is_for_room} = $is_for_room;
    return $self;
}

sub image_hash {
    my ($self, $image_hash) = @_;
    $self->{_image_hash} = $image_hash;
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

    $args->{from} = $self->{_from};

    Ocean::Error::ParamNotFound->throw(
        message => q{'error_type' not found}, 
    ) unless exists $self->{_error_type};

    $args->{error_type} = $self->{_error_type};

    Ocean::Error::ParamNotFound->throw(
        message => q{'error_reason' not found}, 
    ) unless exists $self->{_error_reason};

    $args->{error_reason} = $self->{_error_reason};

    $args->{error_text} = $self->{_error_text} || '';
    $args->{is_for_room} = $self->{_is_for_room} ? 1 : 0;
    $args->{show} = $self->{_show} || '';
    $args->{status} = $self->{_status} || '';
    $args->{image_hash} = $self->{_image_hash}
        if $self->{_image_hash};

    return $args;
}

1;
