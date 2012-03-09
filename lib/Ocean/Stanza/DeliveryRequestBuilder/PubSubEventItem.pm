package Ocean::Stanza::DeliveryRequestBuilder::PubSubEventItem;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::DELIVER_PUBSUB_EVENT }

sub id {
    my ($self, $id) = @_;
    $self->{_id} = $id;
    return $self;
}

sub name {
    my ($self, $name) = @_;
    $self->{_name} = $name;
    return $self;
}

sub namespace {
    my ($self, $namespace) = @_;
    $self->{_namespace} = $namespace;
    return $self;
}

sub add_field {
    my ($self, $key, $value) = @_;
    $self->{_fields} ||= {};
    $self->{_fields}{$key} = $value;;
    return $self;
}

sub build_args {
    my $self = shift;

    my $args = {};

    Ocean::Error::ParamNotFound->throw(
        message => q{'id' not found}, 
    ) unless exists $self->{_id};

    $args->{id} = $self->{_id};

    Ocean::Error::ParamNotFound->throw(
        message => q{'name' not found}, 
    ) unless exists $self->{_name};

    $args->{name} = $self->{_name};

    Ocean::Error::ParamNotFound->throw(
        message => q{'namespace' not found}, 
    ) unless exists $self->{_namespace};

    $args->{namespace} = $self->{_namespace};

    $args->{fields} = $self->{_fields} || +{};
    return $args;
}

1;
