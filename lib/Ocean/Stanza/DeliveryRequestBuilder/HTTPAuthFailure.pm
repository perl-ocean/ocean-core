package Ocean::Stanza::DeliveryRequestBuilder::HTTPAuthFailure;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::HTTP_AUTH_FAILURE }

sub stream_id {
    my ($self, $stream_id) = @_;
    $self->{_stream_id} = $stream_id;
    return $self;
}

sub build_args {
    my $self = shift;

    my $args = {};

    Ocean::Error::ParamNotFound->throw(
        message => q{'stream_id' not found}, 
    ) unless exists $self->{_stream_id};

    $args->{stream_id} = $self->{_stream_id};

    return $args;
}

1;
