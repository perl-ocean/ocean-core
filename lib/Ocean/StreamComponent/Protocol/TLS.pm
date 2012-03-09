package Ocean::StreamComponent::Protocol::TLS;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::Protocol';

use Ocean::Error;
use Ocean::Constants::StreamErrorType;
use Ocean::Constants::ProtocolPhase;
use Ocean::XML::Namespaces qw(SASL TLS);

sub _initialize {
    my $self = shift;
    $self->{_negotiating} = 0;
}

sub on_client_received_starttls {
    my $self = shift;

    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::HOST_UNKNOWN, 
    ) if $self->{_negotiating};

    $self->{_negotiating} = 1;
    $self->{_delegate}->on_protocol_starttls();
}

sub on_client_negotiated_tls {
    my $self = shift;

    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::HOST_UNKNOWN, 
    ) unless $self->{_negotiating};

    $self->{_delegate}->on_protocol_step(
        Ocean::Constants::ProtocolPhase::SASL_STREAM);

}

1;
