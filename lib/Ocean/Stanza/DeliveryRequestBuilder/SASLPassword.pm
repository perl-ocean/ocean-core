package Ocean::Stanza::DeliveryRequestBuilder::SASLPassword;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::DELIVER_SASL_PASSWORD }

sub stream_id {
    my ($self, $stream_id) = @_;
    $self->{_stream_id} = $stream_id;
    return $self;
}

sub password {
    my ($self, $password) = @_;
    $self->{_password} = $password;
    return $self;
}

sub build_args {
    my $self = shift;

    my $args = {};

    Ocean::Error::ParamNotFound->throw(
        message => q{'stream_id' not found}, 
    ) unless exists $self->{_stream_id};

    $args->{stream_id} = $self->{_stream_id};

    Ocean::Error::ParamNotFound->throw(
        message => q{'password' not found}, 
    ) unless exists $self->{_password};

    $args->{password} = $self->{_password};

    return $args;
}

1;
