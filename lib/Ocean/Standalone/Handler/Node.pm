package Ocean::Standalone::Handler::Node;

use strict;
use warnings;

use parent 'Ocean::Handler::Node';

sub on_node_init {
    my ($self, $ctx, $args) = @_;
    # do nothing
}

sub on_node_timer_report {
    my ($self, $ctx, $args) = @_;
    # do nothing
}

sub on_node_exit {
    my ($self, $ctx, $args) = @_;
    # do nothing
}

1;
