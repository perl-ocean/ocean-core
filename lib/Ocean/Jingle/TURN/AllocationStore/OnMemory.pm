package Ocean::Jingle::TURN::AllocationStore::OnMemory;

use strict;
use warnings;

use parent 'Ocean::Jingle::TURN::AllocationStore';

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _store => {},
    }, $class;
}

sub register_allocation {
    my ($self, $allocation) = @_;
    $self->{_store}{ $allocation->relayed_transport_address } =
        $allocation;
}

sub find_allocation_by_relayed_transport_address {
    my ($self, $address) = @_;
    return $self->{_store}{$address};
}

1;
