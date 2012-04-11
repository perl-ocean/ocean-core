package Ocean::Jingle::STUN::TCPConnection;

use strict;
use warnings;

use Log::Minimal;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _address    => $args{address},
        _socket     => $args{socket},
        _is_closing => 0,
        _delegate   => undef,
    }, $class;
    $self->initialize();
    return $self;
}

sub initialize {
    my $self = shift;
    $self->{_socket}->set_delegate($self);
}

sub address { $_[0]->{_address} }

sub set_delegate {
    my ($self, $delegate) = @_;
    $self->{_delegate} = $delegate;
}

sub release {
    my $self = shift;
    if ($self->{_socket}) {
        $self->{_socket}->release();
        delete $self->{_socket};
    }
    if ($self->{_delegate}) {
        delete $self->{_delegate};
    }
}

sub write {
    my ($self, $data) = @_;
    $self->{_socket}->push_write($data);
}

sub is_closing {
    my $self = shift;
    return $self->{_is_closing};
}

sub close {
    my $self = shift;
    return if $self->{_is_closing};
    $self->{_is_closing} = 1;
    $self->{_socket}->close();
}

sub on_socket_read_data {
    my ($self, $data) = @_;
    $self->{_delegate}->on_connection_read_data(
        $self->{_address}, $$data);
}

sub on_socket_timeout {
    my $self = shift;
    infof('<Connection> @timeout');
    $self->close();
}

sub on_socket_eof {
    my $self = shift;
    $self->close();
}

sub on_socket_closed {
    my $self = shift;
    $self->{_delegate}->on_connection_closed(
        $self->{_address});
}

1;
