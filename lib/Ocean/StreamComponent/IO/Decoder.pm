package Ocean::StreamComponent::IO::Decoder;

use strict;
use warnings;

use Ocean::Error;

sub set_delegate {
    my ($self, $delegate) = @_;
    Ocean::Error::AbstractMethod->throw;
}

sub release_delegate {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw;
}

sub initialize {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw;
}

sub feed {
    my ($self, $data) = @_;
    Ocean::Error::AbstractMethod->throw;
}

sub release {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw;
}

1;
