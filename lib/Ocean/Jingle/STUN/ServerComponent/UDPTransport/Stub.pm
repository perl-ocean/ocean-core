package Ocean::Jingle::STUN::ServerComponent::UDPTransport::Stub;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::ServerComponent::UDPTransport';

sub start {
    my $self = shift;
    $self->{_send_queue} = [];
}

sub emulate_client_error {
    my ($self, $fatal, $message) = @_;
    $self->{_delegate}->on_transport_error($fatal, $message);
}

sub emulate_client_recv {
    my ($self, $bytes, $from) = @_;
    $self->{_delegate}->on_transport_received_message($bytes, $from);
}

sub send {
    my ($self, $bytes, $to) = @_;
    push( @{ $self->{_send_queue} }, [$bytes, $to] );
}

sub stop {
    my $self = shift;
    # do nothing
}

1;
