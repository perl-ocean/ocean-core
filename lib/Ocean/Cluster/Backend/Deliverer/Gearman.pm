package Ocean::Cluster::Backend::Deliverer::Gearman;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::Deliverer';

use Ocean::Constants::Cluster;

use Log::Minimal;
use Gearman::Client;
use Gearman::Task;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _nodes          => {},
        _priorities     => {},
        priorities      => $args{priorities},
        node_inboxes    => $args{node_inboxes},
    }, $class;
    return $self;
}

sub _create_gearman_clients {
    my ($self, $node_inboxes) = @_;
    for my $node_inbox ( @$node_inboxes ) {
        $self->register_node($node_inbox->{node_id}, [$node_inbox->{address}]);
    }
}

sub _initialize_priority_map {
    my ($self, $priority_list) = @_;

    foreach my $priority (@$priority_list) {
        $self->{_priorities}->{$priority->{name}} = $priority->{level};
    }
}

sub initialize {
    my $self = shift;
    infof('<Deliverer> @initialize');
    $self->_create_gearman_clients(delete $self->{node_inboxes});
    $self->_initialize_priority_map(delete $self->{priorities});
}

sub register_node {
    my ($self, $name, $servers) = @_;
    unless (exists $self->{_nodes}{$name}) {
        $self->{_nodes}{$name} = 
            $self->create_client($servers);
    }
}

sub create_client {
    my ($self, $servers) = @_;

    infof("<Deliverer> create client for servers [%s]", join(",", @$servers));

    my $client = Gearman::Client->new();
    $client->job_servers(@$servers);
    return $client;
}

sub get_client {
    my ($self, $node_id) = @_;
    return $self->{_nodes}{$node_id};
}

sub create_task {
    my ($self, $node_id, $data) = @_;
    return Gearman::Task->new($node_id, $data, {});
}

sub deliver {
    my ($self, $node_id, $data, $type) = @_;
    my $client = $self->get_client($node_id);
    if ($client) {
        my $is_high_priority = defined $self->{_priorities}->{$type} and $self->{_priorities}->{$type} eq 'high' ? 1 : 0;
        my $task = $self->create_task($node_id, \$data, +{ high_priority => $is_high_priority });
        $client->dispatch_background($task);
    } else {
        warnf("<Deliverer> client for host [%s] not found", $node_id);
    }
}

1;
