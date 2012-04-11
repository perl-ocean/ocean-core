package Ocean::Jingle::TURN::AllocationStore;

use strict;
use warnings;

use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    return bless \%args, $class;
}

sub register_allocation {
    my ($self, $allocation) = @_;
    Ocean::Error::AbstractMethod->throw;
}

sub find_allocation_by_relayed_transport_address {
    my ($self, $address) = @_;
    Ocean::Error::AbstractMethod->throw;
}

1;
