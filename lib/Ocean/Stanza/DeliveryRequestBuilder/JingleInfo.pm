package Ocean::Stanza::DeliveryRequestBuilder::JingleInfo;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::DELIVER_JINGLE_INFO }

sub to {
    my ($self, $to_jid) = @_;
    $self->{_to} = "$to_jid";
    return $self;
}

sub request_id {
    my ($self, $request_id) = @_;
    $self->{_request_id} = "$request_id";
    return $self;
}

sub from {
    my ($self, $from) = @_;
    $self->{_from} = "$from";
    return $self;
}

sub token {
    my ($self, $token) = @_;
    $self->{_token} = $token;
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
        message => q{'request_id' not found}, 
    ) unless exists $self->{_request_id};

    $args->{id} = $self->{_request_id};

    $args->{token} = $self->{_token};

    return $args;
}

1;
