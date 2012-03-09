package Ocean::Stanza::DeliveryRequestBuilder::RoomMembersListItem;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Config;
use Ocean::JID;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::DELIVER_DISCO_ITEMS }

sub jid {
    my ($self, $jid) = @_;
    $self->{_jid} = "$jid";
    return $self;
}

sub name {
    my ($self, $name) = @_;
    $self->{_name} = $name;
    return $self;
}

sub build_args {
    my $self = shift;

    my $args = {};

    Ocean::Error::ParamNotFound->throw(
        message => q{'room_id' not found}, 
    ) unless exists $self->{_jid};

    $args->{jid} = $self->{_jid};

    Ocean::Error::ParamNotFound->throw(
        message => q{'room_name' not found}, 
    ) unless exists $self->{_name};

    $args->{name} = $self->{_name};

    return $args;
}

1;

