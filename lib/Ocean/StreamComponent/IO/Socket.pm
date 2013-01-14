package Ocean::StreamComponent::IO::Socket;

use strict;
use warnings;

use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    my $self = bless {%args}, $class;
    return $self;
}

sub host { $_[0]->{_host} }
sub port { $_[0]->{_port} }

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
        message => q{Ocean::StreamComponent::IO::Socket::shutdown}, 
    );
}

sub close {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamComponent::IO::Socket::close}, 
    );
}

sub accept_tls {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamComponent::IO::Socket::accept_tls}, 
    );
}

sub push_write {
    my ($self, $data) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamComponent::IO::Socket::push_write}, 
    );
}

sub on_stream_upgraded_to_available {
    my $self = shift;
    # do nothing
}

1;
