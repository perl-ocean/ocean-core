package Ocean::Stanza::DeliveryRequestBuilder::RoomInfo;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Config;
use Ocean::JID;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::DELIVER_ROOM_INFO }

sub room_name {
    my ($self, $room) = @_;
    $self->{_room} = $room;
    return $self;
}

sub room_nickname {
    my ($self, $name) = @_;
    $self->{_name} = $name;
    return $self;
}

sub to {
    my ($self, $to) = @_;
    $self->{_to} = "$to";
    return $self;
}

sub request_id {
    my ($self, $request_id) = @_;
    $self->{_request_id} = $request_id;
    return $self;
}

sub build_args {
    my $self = shift;

    my $args = {};

    Ocean::Error::ParamNotFound->throw(
        message => q{'room' not found},
    ) unless exists $self->{_room};

    $args->{_from} = Ocean::JID->build(
        $self->{_room},
        Ocean::Config->instance->get(muc => q{domain})
    )->as_bare_string;

    Ocean::Error::ParamNotFound->throw(
        message => q{'to' not found},
    ) unless exists $self->{_to};

    $args->{to} = $self->{_to};

    Ocean::Error::ParamNotFound->throw(
        message => q{'request_id' not found},
    ) unless exists $self->{_request_id};

    $args->{id} = $self->{_request_id};

    $args->{identities} = [{
        category => 'conference',
        type     => 'text',
        name     => $self->{_name} || $self->{_room},
    }];

    # $args->{features} = [
    #
    # ];

    return $args;
}

1;

