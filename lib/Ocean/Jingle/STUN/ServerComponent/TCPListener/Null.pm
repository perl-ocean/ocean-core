package Ocean::Jingle::STUN::ServerComponent::TCPListener::Null;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::ServerComponent::TCPListener';

sub start {
    my $self = shift;
    # do nothing
}

sub stop {
    my $self = shift;
    # do nothing
}

1;
