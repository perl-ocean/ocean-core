package Ocean::Stanza::DeliveryRequestBuilder::TowardRoomMemberIQ;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::DELIVER_IQ_TOWARD_USER }

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

sub request_id {
    my ($self, $request_id) = @_;
    $self->{_request_id} = $request_id;
    return $self;
}

sub query_type {
    my ($self, $type) = @_;
    $self->{_type} = $type;
    return $self;
}

sub raw {
    my ($self, $raw) = @_;
    $self->{_raw} = "$raw";
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
        message => q{'type' not found}, 
    ) unless exists $self->{_type};

    $args->{type} = $self->{_type};

    Ocean::Error::ParamNotFound->throw(
        message => q{'raw' not found}, 
    ) unless exists $self->{_raw};

    $args->{raw} = $self->{_raw};

    Ocean::Error::ParamNotFound->throw(
        message => q{'request_id' not found}, 
    ) unless exists $self->{_request_id};

    $args->{request_id} = $self->{_request_id};

    return $args;
}

1;
