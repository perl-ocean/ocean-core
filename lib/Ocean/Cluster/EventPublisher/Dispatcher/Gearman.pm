package Ocean::Cluster::EventPublisher::Dispatcher::Gearman;

use strict;
use warnings;

use parent 'Ocean::Cluster::EventPublisher::Dispatcher';

use Ocean::Constants::Cluster;
use Gearman::Client;

sub new {
    my ($class, %args) = @_;
    my $self = bless {}, $class;
    $self->{_gearman} = Gearman::Client->new;
    $self->{_gearman}->job_servers($args{job_servers}||[]);
    $self->{_queue_name} = $args{queue_name}||Ocean::Constants::Cluster::QUEUE_NAME;
    return $self;
}

sub dispatch {
    my ($self, $data) = @_;
    $self->{_gearman}->dispatch_background(
        $self->{_queue_name},
        $data,
    );
}

1;
