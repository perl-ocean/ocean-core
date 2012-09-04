package Ocean::Stanza::DeliveryRequestBuilder::RoomMembersList;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Config;
use Ocean::Constants::EventType;
use Ocean::Error;
use Ocean::JID;

sub type  { Ocean::Constants::EventType::DELIVER_ROOM_MEMBERS_LIST }

sub request_id {
    my ($self, $id) = @_;
    $self->{_id} = $id;
    return $self;
}

sub room {
    my ($self, $room) = @_;
    $self->{_room} = $room;
    return $self;
}

sub to {
    my ($self, $to) = @_;
    $self->{_to} = "$to";
    return $self;
}

sub _item_builders {
    my $self = shift;
    if (exists $self->{_item_builders}) {
        $self->{_item_builders} = [];
    }
    return $self->{_item_builders};
}

sub add_item_builder {
    my ($self, $item_builder) = @_;
    push(@{$self->{_item_builders}}, $item_builder);
    return $self;
}

sub build_args {
    my $self = shift;

    my $args = {};

    Ocean::Error::ParamNotFound->throw(
        message => q{'room' not found},
    ) unless exists $self->{_room};

    my $muc_domain = Ocean::Config->instance->get(muc => q{domain});
    $args->{from} = Ocean::JID->build($self->{_room}, $muc_domain)->as_bare_string;

    Ocean::Error::ParamNotFound->throw(
        message => q{'id' not found},
    ) unless exists $self->{_id};

    $args->{id} = $self->{_id};

    Ocean::Error::ParamNotFound->throw(
        message => q{'to' not found},
    ) unless exists $self->{_to};

    $args->{to} = $self->{_to};

    my $items = [];
    for my $item_builder( @{ $self->{_item_builders} } ) {
        push(@$items, $item_builder->build_args());
    }
    $args->{items} = $items;

    return $args;
}

1;

