package Ocean::Stanza::DeliveryRequestBuilder::RoomInvitation;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Config;
use Ocean::JID;
use Ocean::Constants::EventType;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::DELIVER_ROOM_INVITATION }

sub room {
    my ($self, $room) = @_;
    $self->{_room} = $room;
    return $self;
}

sub from {
    my ($self, $from) = @_;
    $self->{_invitor} = $from;
    return $self;
}

sub to {
    my ($self, $to) = @_;
    $self->{_to} = "$to";
    return $self;
}

sub reason {
    my ($self, $reason) = @_;
    $self->{_reason} = $reason;
    return $self;
}

sub thread {
    my ($self, $thread) = @_;
    $self->{_thread} = $thread;
    return $self;
}

sub build_args {
    my $self = shift;

    my $args = {};

    my $muc_domain = Ocean::Config->instance->get(muc => q{domain});

    Ocean::Error::ParamNotFound->throw(
        message => q{'room' not found}, 
    ) unless exists $self->{_room};

    $args->{from} = Ocean::JID->build(
        $self->{_room}, $muc_domain)->as_bare_string;

    Ocean::Error::ParamNotFound->throw(
        message => q{'to' not found}, 
    ) unless exists $self->{_to};

    $args->{to} = $self->{_to};

    Ocean::Error::ParamNotFound->throw(
        message => q{'from' not found}, 
    ) unless exists $self->{_invitor};

    $args->{invitor} = $self->{_invitor};

    $args->{reason} = $self->{_reason} || '';
    $args->{thread} = $self->{_thread} || '';

    return $args;
}

1;

