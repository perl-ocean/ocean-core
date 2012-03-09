package Ocean::Cluster::Backend::Deliverer;

use strict;
use warnings;

use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    my $self = bless \%args, $class;
    return $self;
}

sub deliver {
    my ($self, $node_id, $data) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Cluster::Backend::Deliverer::dispatch}, 
    );
}

1;
