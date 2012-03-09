package Ocean::Stanza::DeliveryRequestBuilder::RoomListItem;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Config;
use Ocean::JID;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::DELIVER_DISCO_ITEMS }

sub room_name {
    my ($self, $room_id) = @_;
    $self->{_jid} = Ocean::JID->build(
        $room_id, 
        Ocean::Config->instance->get(muc => q{domain})
    )->as_bare_string;
    return $self;
}

sub room_nickname {
    my ($self, $name) = @_;
    $self->{_name} = $name;
    return $self;
}

sub build_args {
    my $self = shift;

    my $args = {};

    Ocean::Error::ParamNotFound->throw(
        message => q{'room_name' not found}, 
    ) unless $self->{_jid};

    $args->{jid} = $self->{_jid};

    $args->{name} = $self->{_name} || $args->{jid};

    return $args;
}

1;

