package Ocean::Cluster::Backend::NodeEventHandler;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::EventHandler';

use Try::Tiny;

sub dispatch {
    my ($self, $event_type, $ctx, $node_id, $args, $rethrow) = @_;

    my $method = $self->event_method_map->{$event_type};
    unless ($method) {
        $self->log_warn('Unsupported event type: %s', $event_type);
        return;
    }
    try {
        $self->$method($ctx, $node_id, $args);
    } catch {
        $self->log_crit('Caught an exception at %s: %s', $event_type, $_);
        die $_ if $rethrow;
    };
}

1;
