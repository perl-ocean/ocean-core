package Ocean::Standalone::Cluster::Backend::Handler::Worker;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::Handler::Worker';

sub on_worker_init {
    my ($self, $ctx, $args) = @_;
}

sub on_worker_exit {
    my ($self, $ctx, $args) = @_;
}

1;
