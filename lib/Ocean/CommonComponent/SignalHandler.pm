package Ocean::CommonComponent::SignalHandler;

use strict;
use warnings;

use Ocean::Error;

sub new { 
    my $class = shift;
    my $self = bless { 
        _delegate => undef,
        _handlers => {},
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

sub setup {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::CommonComponent::SignalHandler::setup}, 
    );
}

sub DESTROY {
    my $self = shift;
    $self->release();
}

1;
