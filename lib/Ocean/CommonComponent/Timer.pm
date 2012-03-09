package Ocean::CommonComponent::Timer;

use strict;
use warnings;

use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _delegate => undef, 
    }, $class;
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

sub start {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::CommonComponent::Timer::start}, 
    );
}

sub stop {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::CommonComponent::Timer::stop}, 
    );
}

1;
