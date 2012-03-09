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
        _nodes => {}, 
    }, $class;
    return $self;
}

sub initialize {
    my $self = shift;
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
    my ($self, $node_id, $data) = @_;
    my $client = $self->get_client($node_id);
    if ($client) {
        my $task = $self->create_task($node_id, \$data);
        $client->dispatch_background($task);
    } else {
        warnf("<Deliverer> client for host [%s] not found", $node_id);
    }
}

1;
