package Ocean::ServerComponent::Listener::Stub;

use strict;
use warnings;

use parent 'Ocean::ServerComponent::Listener';
use Ocean::StreamComponent::IO::Socket::Stub;

# LISTENER INTERFACE
sub start {
    my $self = shift;
    $self->{_delegate}->on_listener_prepare(
        undef, $self->{_host}, $self->{_port});
}

sub stop {
    my $self = shift;
    # do nothing
}

# FOR TEST
sub emulate_accept {
    my ($self, $dummy_client_id, $dummy_host, $dummy_port) = @_;
    my $client_socket = $self->create_client($dummy_host, $dummy_port);
    $self->{_delegate}->on_listener_accept($dummy_client_id, $client_socket);
    return $client_socket;
}

sub create_client {
    my ($self, $dummy_host, $dummy_port) = @_;
    $dummy_host ||= 'localhost';
    $dummy_port ||= 5222;
    my $client_socket = Ocean::StreamComponent::IO::Socket::Stub->new(
        host => $dummy_host,
        port => $dummy_port,
    );
    return $client_socket;
}

1;
