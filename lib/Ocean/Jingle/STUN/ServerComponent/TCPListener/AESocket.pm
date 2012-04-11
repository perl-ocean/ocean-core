package Ocean::Jingle::STUN::ServerComponent::TCPListener::AESocket;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::ServerComponent::TCPListener';

use Ocean::Config;
use Ocean::Error;
use Ocean::Util::TLS;
use Ocean::Jingle::STUN::TCPConnectionComponent::Socket::AEHandleAdapter;

use AnyEvent::Socket;
use AnyEvent::Handle;
use Log::Minimal;
use Socket ();

sub start {
    my $self = shift;
    $self->{_listener} = AnyEvent::Socket::tcp_server(
        $self->{_host}, 
        $self->{_port}, 
        sub {
            my ($sock, $host, $port) = @_;
            $self->_on_accept($sock, $host, $port);
        },
        sub {
            $self->{_delegate}->on_tcp_listener_prepare(@_);
            return $self->{_backlog};
        }
    );
}

sub create_handle {
    my ($self, $sock) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Jingle::STUN::ServerComponent::TCPListener::AESocket::create_handle not implemented}, 
    );
}

sub create_adapter {
    my ($self, $host, $port, $handle) = @_;
    return Ocean::Jingle::STUN::TCPConnectionComponent::Socket::AEHandleAdapter->new(
        handle => $handle,
    );
}

sub _on_accept {
    my ($self, $sock, $host, $port) = @_;

    infof("<Server> Here comes new connection %s:%d",
        $host, $port);

    # $self->_set_sock_options($sock);

    my $handle = $self->create_handle($sock); 

    my $client_socket = $self->create_adapter($host, $port, $handle);

    my $address = AnyEvent::Socket::pack_sockaddr(
        $port, AnyEvent::Socket::parse_address($host));

    $self->{_delegate}->on_tcp_listener_accept(
        $address,  $client_socket)
}

sub stop {
    my $self = shift;
    delete $self->{_listener}
        if $self->{_listener};
}

1;
