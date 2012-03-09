package Ocean::Cluster::Frontend::Dispatcher;

use strict;
use warnings;

use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
    
    }, $class;
    return $self;
}

sub dispatch {
    my ($self, %params) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Cluster::Frontend::Dispatcher::dispatch}, 
    );
}

sub register_broker_client {
    my ($self, $broker_id, $servers) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Cluster::Frontend::Dispatcher::dispatch}, 
    );
}

1;
