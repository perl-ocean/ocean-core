package Ocean::Stanza::DeliveryRequestBuilder::Presence;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::DELIVER_PRESENCE  }

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

sub raw_jid {
    my ($self, $raw_jid) = @_;
    $self->{_raw_jid} = "$raw_jid";
    return $self;
}

sub add_room_status {
    my ($self, $status) = @_;
    unless (exists $self->{_room_statuses}) {
        $self->{_room_statuses} = [];
    }
    push @{ $self->{_room_statuses} }, $status;
    return $self;
}

sub image_hash {
    my ($self, $image_hash) = @_;
    $self->{_image_hash} = $image_hash;
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

    $args->{is_for_room} = $self->{_is_for_room} ? 1 : 0;

    $args->{show} = $self->{_show} || '';
    $args->{status} = $self->{_status} || '';
    $args->{raw_jid} = $self->{_raw_jid} || '';
    $args->{room_statuses} = $self->{_room_statuses} || [];
    $args->{image_hash} = $self->{_image_hash}
        if $self->{_image_hash};

    return $args;
}

1;
