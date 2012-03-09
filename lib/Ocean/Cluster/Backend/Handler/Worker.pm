package Ocean::Cluster::Backend::Handler::Worker;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::WorkerEventHandler';
use Ocean::Error;
use Ocean::Constants::EventType;

use Log::Minimal;

sub log_debug {
    my $self     = shift;
    my $template = shift;
    debugf('<Handler::Worker> ' . $template, @_);
}

sub log_info {
    my $self     = shift;
    my $template = shift;
    infof('<Handler::Worker> ' . $template, @_);
}

sub log_warn {
    my $self     = shift;
    my $template = shift;
    warnf('<Handler::Worker> ' . $template, @_);
}

sub log_crit {
    my $self     = shift;
    my $template = shift;
    critf('<Handler::Worker> ' . $template, @_);
}

sub event_method_map { +{
    Ocean::Constants::EventType::WORKER_INIT, 
        'on_worker_init',
    Ocean::Constants::EventType::WORKER_EXIT, 
        'on_worker_exit',
} }

sub on_worker_init {
    my ($self, $ctx, $args) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Cluster::Backend::Handler::Worker::on_worker_init}, 
    );
}

sub on_worker_exit {
    my ($self, $ctx, $args) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Cluster::Backend::Handler::Worker::on_worker_exit}, 
    );
}

1;
