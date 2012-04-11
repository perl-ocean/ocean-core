package Ocean::Jingle::STUN::TCPConnectionManager;

use strict;
use warnings;

use Ocean::Error;
use Ocean::Stream;

use AnyEvent::Socket ();
use Log::Minimal;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _server                     => undef,
        _connections                => {},
        _total_connection_counter   => 0,
        _current_connection_counter => 0,
    }, $class;
    return $self;
}

sub set_delegate {
    my ($self, $delegate) = @_;
    $self->{_server} = $delegate;
}

sub release {
    my $self = shift;
    delete $self->{_server};
}

sub register_connection {
    my ($self, $connection) = @_;
    $connection->set_delegate($self);
    $self->{_connections}{$connection->address} = $connection;
    $self->{_current_connection_counter}++;
    $self->{_total_connection_counter}++;
}

sub get_current_connection_counter {
    my $self = shift;
    return $self->{_current_connection_counter};
}

sub get_total_connection_counter {
    my $self = shift;
    return $self->{_total_connection_counter};
}

sub disconnect_all {
    my $self = shift;
    for my $address (keys %{ $self->{_connections} }) {
        my $conn = $self->{_connections}{$address};
        if ($conn && !$conn->is_closing()) {
            $conn->close();
        }
    }
}

sub find_connection_by_address {
    my ($self, $address) = @_;
    return $self->{_connections}{$address};
}

sub on_connection_read_data {
    my ($self, $address, $data) = @_;
    my ($port, $host_bin) = AnyEvent::Socket::unpack_sockaddr($address);
    my $host = AnyEvent::Socket::format_address($host_bin);
    $self->{_server}->on_connection_received_message($host, $port, $data);
}

sub deliver_message {
    my ($self, $host, $port, $bytes) = @_;
    my $address = AnyEvent::Socket::pack_sockaddr(
        $port, AnyEvent::Socket::parse_address($host));
    my $conn = $self->find_connection_by_address($address);
    warnf('<ConnectionManager> connection not found') unless $conn;
    $conn->write($bytes) if $conn;
}

sub on_connection_closed {
    my ($self, $address) = @_;
    my $connection = $self->{_connections}{$address};
    $connection->release() if $connection;
    $self->{_current_connection_counter}--;
    $self->{_server}->on_connection_disconnected();
}

1;
