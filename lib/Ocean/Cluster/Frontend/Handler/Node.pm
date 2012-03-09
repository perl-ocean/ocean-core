package Ocean::Cluster::Frontend::Handler::Node;

use strict;
use warnings;

use parent 'Ocean::Handler::Node';

use Ocean::Constants::EventType;

sub on_node_init {
    my ($self, $ctx, $args) = @_;

    $ctx->post_job(
        Ocean::Constants::EventType::NODE_INIT, 
        {
            node_host  => $args->host,
            node_port  => $args->port,
            inbox_host => $ctx->inbox_host,
            inbox_port => $ctx->inbox_port,
        }
    );
}

sub on_node_timer_report {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::NODE_TIMER_REPORT, 
        {
            total_connection_counter   => $args->total_connection_counter,
            current_connection_counter => $args->current_connection_counter,
        }
    );
}

sub on_node_exit {
    my ($self, $ctx, $args) = @_;

    $ctx->post_job(
        Ocean::Constants::EventType::NODE_EXIT, 
        {
            # empty
        }
    );
}

1;
