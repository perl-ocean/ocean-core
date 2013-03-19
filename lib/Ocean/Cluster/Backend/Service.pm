package Ocean::Cluster::Backend::Service;

use strict;
use warnings;

use Ocean::Constants::EventType;
use Ocean::HandlerArgs::WorkerInitialization;
use Ocean::HandlerArgs::WorkerExit;

use Log::Minimal;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _process_manager   => $args{process_manager}, 
        _fetcher           => $args{fetcher},
        _context           => $args{context},
        _event_dispatcher  => $args{event_dispatcher},
        _serializer        => $args{serializer},
        _deliverer         => $args{deliverer},
        _max_job_per_child => $args{max_job_per_child} || 0,
        _job_counter       => 0,
        _is_stopping       => 0,
    }, $class;
    return $self;
}

sub run {
    my $self = shift;
    $self->service_initialize();
    $self->work();
    $self->service_finalize();
}

sub service_initialize {
    my $self = shift;
    infof('<Service> @initialize');

    $self->{_deliverer}->initialize();
    $self->{_context}->set_delegate($self);
    $self->{_context}->service_initialize();
}

sub service_finalize {
    my $self = shift;
    infof('<Service> @finalize');

    $self->{_context}->service_finalize();
    $self->{_context}->release();
}

sub worker_initialize {
    my $self = shift;

    infof('<Worker:PID:%s> @initialize', $$);

    $self->{_context}->worker_initialize();
    
    $self->{_event_dispatcher}->dispatch_worker_event(
        Ocean::Constants::EventType::WORKER_INIT,
        $self->{_context},
        Ocean::HandlerArgs::WorkerInitialization->new(),
        1,
    );

    $self->{_fetcher}->on_fetch(sub {
        my $job = shift;
        $self->on_fetch_job($job);
    } );
}

sub worker_finalize {
    my $self = shift;

    infof('<Worker:PID:%s> @finalize', $$);


    $self->{_event_dispatcher}->dispatch_worker_event(
        Ocean::Constants::EventType::WORKER_EXIT,
        $self->{_context},
        Ocean::HandlerArgs::WorkerExit->new(),
    );

    $self->{_context}->worker_finalize();

    $self->{_process_manager}->finish();

    # This makes test not to work
    #$self->{_event_dispatcher}->release();
}

sub work {
    my $self = shift;

    infof("<Service> building child workers...");

    while ($self->{_process_manager}->can_continue()) {

        $self->{_process_manager}->start() and next;

        local $SIG{INT}  = sub { $self->on_signal_quit('INT')  };
        local $SIG{TERM} = sub { $self->on_signal_quit('TERM') };

        $self->worker_initialize();

        $self->{_fetcher}->start();

        $self->worker_finalize();
    }

    $self->{_process_manager}->wait_all();

    infof("<Service> joined all child worker processes");
}

sub on_signal_quit {
    my ($self, $sig) = @_;
    return if $self->{_is_stopping};
    infof('<Worker:PID:%d> @quit_signal { signal: %s } ', $$, $sig);
    $self->_child_quit();
}

sub on_signal_refresh {
    my $self = shift;
    infof("<Service> workers have no refresh: please restart the process");
}

sub on_fetch_job {
    my ($self, $raw_job) = @_;

    infof("<Worker:PID:%d> fetched new job", $$);

    my $job = $self->{_serializer}->deserialize($raw_job);
    $self->{_event_dispatcher}->dispatch_job(
        $self->{_context}, $job);
    $self->_on_job_step();
}

sub on_delivery_request {
    my ($self, $node_id, $req) = @_;
    infof('<Deliverer> @%s { node: %s }', $req->type, $node_id);
    my $data = $self->{_serializer}->serialize($req->as_hash());
    $self->{_deliverer}->deliver($node_id, $data, $req->type);
}

sub _on_job_step {
    my $self = shift;
    $self->_update_stats();
    $self->_report_stats();
    $self->_check_stats();
}

sub _update_stats {
    my $self = shift;
    $self->{_job_counter}++;
}

sub _report_stats {
    my $self = shift;
    my $total = $self->{_job_counter};
    if ($total != 1) {
        infof("<Worker:PID:%d> handled %d jobs", $$, $total);
    }
    else {
        infof("<Worker:PID:%d> handled first job", $$, $total);
    }
}

sub _check_stats {
    my $self = shift;
    return if $self->{_is_stopping};
    if (   $self->{_max_job_per_child} > 0 
        && $self->{_job_counter} >= $self->{_max_job_per_child}) {
        infof("<Worker:PID:%d> handled jobs over limit", $$);
        $self->_child_quit();
    }
}

sub _child_quit {
    my $self = shift;
    $self->{_is_stopping} = 1;
    infof("<Worker:PID:%d> quit loop", $$);
    $self->{_fetcher}->stop();
}

1;
