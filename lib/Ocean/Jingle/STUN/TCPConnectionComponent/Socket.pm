package Ocean::Jingle::STUN::TCPConnectionComponent::Socket;

use strict;
use warnings;

use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    my $self = bless {%args}, $class;
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

sub shutdown {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Jingle::STUN::TCPConnectionComponent::Socket::shutdown}, 
    );
}

sub close {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Jingle::STUN::TCPConnectionComponent::Socket::close}, 
    );
}

sub push_write {
    my ($self, $data) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Jingle::STUN::TCPConnectionComponent::Socket::push_write}, 
    );
}

1;
