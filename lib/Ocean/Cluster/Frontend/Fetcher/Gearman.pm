package Ocean::Cluster::Frontend::Fetcher::Gearman;

use strict;
use warnings;

use parent 'Ocean::Cluster::Frontend::Fetcher';

use AnyEvent::Gearman::Worker;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _on_fetch_event => sub {},
        _worker         => undef,
        _node_id        => $args{node_id},
        _inbox_host     => $args{inbox_host},
        _inbox_port     => $args{inbox_port},
    }, $class;
    $self->_initialize();
    return $self;
}

sub inbox_host { $_[0]->{_inbox_host} }
sub inbox_port { $_[0]->{_inbox_port} }

sub _initialize {
    my $self = shift;
    $self->{_worker} = 
        $self->_create_worker( 
            [join ":", $self->{_inbox_host}, $self->{_inbox_port} ] );
}

sub _create_worker {
    my ($self, $servers) = @_;
    my $worker = AnyEvent::Gearman::Worker->new(
        job_servers => $servers,
    );
    $worker->register_function( $self->{_node_id},
        sub { $self->_on_worker_got_job(@_) },
    );
    return $worker;
}

sub _on_worker_got_job {
    my ($self, $job) = @_;
    $self->{_on_fetch_event}->($job->workload);
    $job->complete('');
}

1;
