package Ocean::Cluster::EventPublisher::Dispatcher;

use strict;
use warnings;

use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    return bless \%args, $class;
}

sub dispatch {
    my ($self, $data) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Cluster::EventPublisher::Dispatcher::dispatch}, 
    );
}

1;
