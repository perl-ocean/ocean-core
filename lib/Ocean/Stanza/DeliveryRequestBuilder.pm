package Ocean::Stanza::DeliveryRequestBuilder;

use strict;
use warnings;

use Ocean::Stanza::DeliveryRequest;
use Ocean::Error;

sub new {
    my $class = shift;
    my $self = bless {
        _args  => {},
    }, $class;
    return $self;
}

sub type {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Stanza::DeliveryRequestBuilder::type}, 
    );
}

sub build_args {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Stanza::DeliveryRequestBuilder::build_args}, 
    );
}

sub build {
    my $self = shift;
    return Ocean::Stanza::DeliveryRequest->new(
        type => $self->type(),
        args => $self->build_args(),
    );
}

1;
