package Ocean::Stanza::DeliveryRequestBuilder::RosterPush;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::DELIVER_ROSTER_PUSH }

sub to_jid {
    my ($self, $to_jid) = @_;
    $self->{_to_jid} = "$to_jid";
    return $self;
}

sub request_id {
    my ($self, $request_id) = @_;
    $self->{_request_id} = $request_id;
    return $self;
}

sub item_builder {
    my ($self, $item_builder) = @_;
    $self->{_item_builder} = $item_builder;
    return $self;
}

sub build_args {
    my $self = shift;

    my $args = {};

    Ocean::Error::ParamNotFound->throw(
        message => q{'to_jid' not found}, 
    ) unless exists $self->{_to_jid};

    $args->{to_jid} = $self->{_to_jid};

    Ocean::Error::ParamNotFound->throw(
        message => q{'request_id' not found}, 
    ) unless exists $self->{_request_id};

    $args->{request_id} = $self->{_request_id};

    Ocean::Error::ParamNotFound->throw(
        message => q{'item_builder' not found}, 
    ) unless exists $self->{_item_builder};

    $args->{item} = $self->{_item_builder}->build_args();

    return $args;
}

1;
