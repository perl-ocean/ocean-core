package Ocean::ServerComponent::Daemonizer;

use strict;
use warnings;

use Ocean::Error;

sub new { bless { }, $_[0] }

sub initialize {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ServerComponent::Daemonizer::initialize},  
    );
}

sub finalize {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ServerComponent::Daemonizer::finalize},  
    );
}

1;
