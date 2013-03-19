package Ocean::Cluster::Backend::ServiceComponentFactory::Gearman;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::ServiceComponentFactory';

use Ocean::Cluster::Backend::Fetcher::Gearman;
use Ocean::Cluster::Backend::Deliverer::Gearman;

sub create_fetcher {
    my $self = shift;

    my $job_servers = Ocean::Config->instance->get(worker => q{broker_servers});
    my $queue_name  = Ocean::Config->instance->get(worker => q{queue_name});
    my $fetcher = 
        Ocean::Cluster::Backend::Fetcher::Gearman->new(
            job_servers => $job_servers,
            queue_name  => $queue_name,
        );
    return $fetcher;
}

sub create_deliverer {
    my $self = shift;

    my $node_inboxes = Ocean::Config->instance->get(worker => q{node_inboxes});
    my $override_priorities = Ocean::Config->instance->get(worker => q{override_priorities});

    my $deliverer = Ocean::Cluster::Backend::Deliverer::Gearman->new(
        priorities      => $override_priorities,
        node_inboxes    => $node_inboxes,
    );

    return $deliverer;
}

1;
