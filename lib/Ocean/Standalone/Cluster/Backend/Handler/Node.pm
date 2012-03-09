package Ocean::Standalone::Cluster::Backend::Handler::Node;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::Handler::Node';

sub on_node_init {
    my ($self, $ctx, $node_id, $args) = @_;
    # do nothing
}

sub on_node_timer_report {
    my ($self, $ctx, $node_id, $args) = @_;
    # do nothing
}

sub on_node_exit {
    my ($self, $ctx, $node_id, $args) = @_;
    # do nothing
}

1;
