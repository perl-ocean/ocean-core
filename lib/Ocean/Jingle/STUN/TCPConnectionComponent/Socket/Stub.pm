package Ocean::Jingle::STUN::TCPConnectionComponent::Socket::Stub;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::TCPConnectionComponent::Socket';
use Log::Minimal;
use Try::Tiny;
use Carp ();

sub new {
    my ($class, %args) = @_;
    my $self = bless { 
        _on_read  => sub {}, 
        _delegate => undef,
        _closed   => 0,
        %args }, $class;
    return $self;
}

sub set_delegate {
    my ($self, $delegate) = @_;
    $self->{_delegate} = $delegate;
}

sub release {
    my $self = shift;
    delete $self->{_delegate}
        if $self->{_delegate};
}

sub close {
    my $self = shift;
    $self->shutdown();
    $self->{_delegate}->on_socket_closed();
    $self->{_closed} = 1;
}

sub is_closed {
    my $self = shift;
    return $self->{_closed};
}

sub shutdown {
    my $self = shift;
    # do nothing
}

sub push_write {
    my ($self, $data) = @_;
    $self->{_on_read}->($data);
}

# to pick up received events
sub client_on_read {
    my ($self, $callback) = @_;
    $self->{_on_read} = $callback;
}

# to cause clinet events
sub emulate_client_write {
    my ($self, $data) = @_;
    try {
        $self->{_delegate}->on_socket_read_data(\$data);
    } catch {
        Carp::confess $_;
    };
}

sub emulate_client_timeout {
    my $self = shift;
    $self->{_delegate}->on_socket_timeout();
}

sub emulate_client_close {
    my $self = shift;
    $self->{_delegate}->close();
}

1;
