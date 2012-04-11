package Ocean::Jingle::STUN::ServerComponent::UDPTransport::AEHUDP;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::ServerComponent::UDPTransport';
use AnyEvent::Handle::UDP;
use AnyEvent::Socket ();

use Log::Minimal;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _delegate     => undef, 
        _handle       => undef,
        _host         => $args{host},
        _port         => $args{port},
        _receive_size => $args{receive_size} || 1500,
    }, $class;
    return $self;
}

sub _create_handle {
    my $self = shift;
    
    my $handle = AnyEvent::Handle::UDP->new(
        bind => [$self->{_host}, $self->{_port}], 
        receive_size => $self->{_receive_size},
        on_error => sub {
            my ($handle, $fatal, $message) = @_;
            warnf('<UDP> @error %s', $message);
            $self->{_delegate}->on_transport_error($fatal, $message);
        },
        on_recv => sub {
            my ($bytes, $h, $from) = @_;
            debugf('<UDP> @recv');
            my ($port, $host_bin) = AnyEvent::Socket::unpack_sockaddr($from);
            my $host = AnyEvent::Socket::format_address($host_bin);
            $self->{_delegate}->on_transport_received_message($host, $port, $bytes);
        },
    );
}

sub start {
    my $self = shift;
    $self->{_handle} = $self->_create_handle();
    $self->{_delegate}->on_transport_bound($self->{_host}, $self->{_port});
}

sub send {
    my ($self, $host, $port, $bytes) = @_;
    my $to = AnyEvent::Socket::pack_sockaddr(
        $port, AnyEvent::Socket::parse_address($host));
    $self->{_handle}->push_send($bytes, $to);
}

sub stop {
    my $self = shift;
    if ($self->{_handle}) {
        $self->{_handle}->destroy();
        delete $self->{_handle};
    }
}

sub release {
    my $self = shift;
    if ($self->{_delegate}) {
        delete $self->{_delegate};
    }
    if ($self->{_handle}) {
        $self->{_handle}->destroy();
        delete $self->{_handle};
    }
}

1;
