package Ocean::Stanza::DeliveryRequestBuilder::Roster;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::DELIVER_ROSTER }

sub to {
    my ($self, $to_jid) = @_;
    $self->{_to} = "$to_jid";
    return $self;
}

sub request_id {
    my ($self, $request_id) = @_;
    $self->{_request_id} = $request_id;
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
        message => q{'request_id' not found}, 
    ) unless exists $self->{_request_id};

    $args->{request_id} = $self->{_request_id};

    my $items = [];
    for my $item_builder( @{ $self->{_item_builders} } ) {
        push(@$items, $item_builder->build_args());
    }
    $args->{items} = $items;

    return $args;
}

1;
