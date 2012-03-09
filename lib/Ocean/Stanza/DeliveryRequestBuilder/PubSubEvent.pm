package Ocean::Stanza::DeliveryRequestBuilder::PubSubEvent;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::DELIVER_PUBSUB_EVENT }

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

sub node {
    my ($self, $node) = @_;
    $self->{_node} = $node;
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
        message => q{'to' not found}, 
    ) unless exists $self->{_to};

    $args->{to} = $self->{_to};

    Ocean::Error::ParamNotFound->throw(
        message => q{'from' not found}, 
    ) unless exists $self->{_from};

    $args->{from} = $self->{_from};

    Ocean::Error::ParamNotFound->throw(
        message => q{'node' not found}, 
    ) unless exists $self->{_node};

    $args->{node} = $self->{_node};

    my $items = [];
    for my $item_builder( @{ $self->{_item_builders} } ) {
        push(@$items, $item_builder->build_args());
    }
    $args->{items} = $items;

    return $args;
}

1;
