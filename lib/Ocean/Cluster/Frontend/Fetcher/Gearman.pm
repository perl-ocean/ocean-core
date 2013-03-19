package Ocean::Cluster::Frontend::Fetcher::Gearman;

use strict;
use warnings;

use parent 'Ocean::Cluster::Frontend::Fetcher';

use constant DEFAULT_NO_OF_WORKER_CONNECTIONS => 30;

use AnyEvent::Gearman::Worker;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _on_fetch_event => sub {},
        _worker         => undef,
        _node_id        => $args{node_id},
        _no_workers     => $args{no_workers},
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
    my @servers;

    $self->{_no_workers} = DEFAULT_NO_OF_WORKER_CONNECTIONS
        unless $self->{_no_workers};

    for ( 1 .. $self->{_no_workers} ) {
        push(@servers, join(":", $self->{_inbox_host}, $self->{_inbox_port}));
    }

    $self->{_worker} =
        $self->_create_worker( \@servers );
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

sub destroy {
    my $self = shift;
    for my $js (@{ $self->{_worker}->job_servers }) {
        $js->mark_dead;
    }

    $self->{_worker} = undef;
    $self->{_on_fetch_event} = undef;
}

1;
