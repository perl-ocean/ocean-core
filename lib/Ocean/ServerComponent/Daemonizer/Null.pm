package Ocean::ServerComponent::Daemonizer::Null;

use strict;
use warnings;

use parent 'Ocean::ServerComponent::Daemonizer';

sub initialize {
    my $self = shift;
    # do nothing
}

sub finalize {
    my $self = shift;
    # do nothing
}

1;
