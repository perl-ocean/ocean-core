package Ocean::Cluster::Frontend::Dispatcher::Gearman;

use strict;
use warnings;

use parent 'Ocean::Cluster::Frontend::Dispatcher';

use Gearman::Client;
use Log::Minimal;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _brokers => {},
    }, $class;
    return $self;
}

sub register_broker_client {
    my ($self, $broker_id, $servers) = @_;
    if (exists $self->{_brokers}{$broker_id}) {
        warnf("<Handler> <Dispatcher> a client for broker '%s' already exists", $broker_id);
        return;
    }
    my $client = $self->_create_broker_client($servers);
    $self->{_brokers}{$broker_id} = $client;
}

sub _create_broker_client {
    my ($self, $servers) = @_;
    my $client = Gearman::Client->new;
    $client->job_servers(@$servers);
    return $client;
}

sub _get_broker_client {
    my ($self, $broker_id) = @_;
    return $self->{_brokers}{$broker_id};
}

sub dispatch {
    my ($self, %params) = @_;


    my $broker_id  = $params{broker_id};
    my $queue_name = $params{queue_name};
    my $data       = $params{data};

    debugf('<Handler> @dispatch { broker_id: %s, queue_name: %s }', $broker_id, $queue_name);

    my $client = $self->_get_broker_client($broker_id);
    unless ($client) {
        warnf("<Handler> <Dispatcher> unknown broker_id '%s' is indicated for dispatching", $broker_id);
        return;
    }
    $client->dispatch_background($queue_name, $data, {});
}

sub destroy {
    my $self = shift;

    $self->{_brokers} = undef;
}

1;
