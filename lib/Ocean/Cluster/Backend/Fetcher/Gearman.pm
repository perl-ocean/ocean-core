package Ocean::Cluster::Backend::Fetcher::Gearman;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::Fetcher';

use Ocean::Constants::Cluster;

use Gearman::Worker;
use Log::Minimal;

sub new {
    my ($class, %args) = @_;

    my $self = bless {
        _job_servers      => $args{job_servers}, 
        _queue_name       => $args{queue_name},
        _required_to_stop => 0,
    }, $class;

    return $self;
}

sub _create_gearman_worker {
    my ($self, $servers) = @_;

    infof("<Fetcher> setup Gearman::Worker for servers - %s", 
        join(",", @$servers));

    my $gearman = Gearman::Worker->new;
    $gearman->job_servers(@$servers);

    $gearman->register_function(
        $self->{_queue_name},
        sub {
            my $job = shift;
            my $callback = $self->{_on_fetch} || sub {};
            $callback->($job->arg);
        },    
    );
    return $gearman;
}

sub start {
    my $self = shift;

    infof("<Fetcher> gearman start to work");

    $self->{_gearman} = 
        $self->_create_gearman_worker($self->{_job_servers});

    unless ($self->{_gearman}) {
        critf("<Fetcher> failed to establish gearman connection");
        return;
    }

    # this line starts loop,
    # doesn't return.
    $self->{_gearman}->work(
        on_fail     => sub { $self->_on_fail(@_)        },
        on_start    => sub { $self->_on_start(@_)       },
        on_complete => sub { $self->_on_complete(@_)    },
        stop_if     => sub { $self->{_required_to_stop} },
    ); 
}

sub stop {
    my $self = shift;
    $self->{_required_to_stop} = 1;
}

sub _on_fail {
    my $self = shift;
    debugf("<Fetcher> Gearman: on_fail");
}

sub _on_start {
    my $self = shift;
    debugf("<Fetcher> Gearman: on_start");
}

sub _on_complete {
    my $self = shift;
    debugf("<Fetcher> Gearman: on_complete");
}

1;
