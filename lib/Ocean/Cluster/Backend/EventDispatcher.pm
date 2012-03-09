package Ocean::Cluster::Backend::EventDispatcher;

use strict;
use warnings;

use parent 'Ocean::HandlerManager';

use Ocean::Error;
use Ocean::Config;
use Ocean::Constants::EventType;
use Ocean::Registrar::EventCategory;

use Ocean::Cluster::Backend::Registrar::DispatchInfo;

use Ocean::HandlerArgs::NodeInitialization;
use Ocean::HandlerArgs::NodeExit;
use Ocean::HandlerArgs::NodeTimerReport;
use Ocean::HandlerArgs::BindRequest;
use Ocean::HandlerArgs::BindRequest;
use Ocean::HandlerArgs::SilentDisconnection;
use Ocean::HandlerArgs::TooManyAuthAttempt;
use Ocean::HandlerArgs::HTTPAuthRequest;
use Ocean::HandlerArgs::SASLAuthRequest;
use Ocean::HandlerArgs::SASLPasswordRequest;
use Ocean::HandlerArgs::SASLSuccessNotification;
use Ocean::HandlerArgs::Message;
use Ocean::HandlerArgs::Presence;
use Ocean::HandlerArgs::InitialPresence;
use Ocean::HandlerArgs::UnavailablePresence;
use Ocean::HandlerArgs::RosterRequest;
use Ocean::HandlerArgs::vCardRequest;
use Ocean::HandlerArgs::PubSubEvent;
use Ocean::HandlerArgs::TowardUserIQ;

use Log::Minimal;
use Try::Tiny;

sub _get_event_args_class {
    my ($self, $event_type) = @_;
    return Ocean::Cluster::Backend::Registrar::DispatchInfo->get($event_type);
}

sub dispatch_job {
    my ($self, $ctx, $job) = @_;

    my $type    = $job->{type}    || '';
    my $node_id = $job->{node_id} || '';

    my $info = $self->_get_event_args_class($type);

    if ($info) {
        try {
            my $args_class = $info->{args_class};

            my $args = $args_class->new($job->{args});
            $self->dispatch_node_event($type, $ctx, $node_id, $args);
        } catch {
            critf('<Dispatcher> failed to handle job: %s', $_);
        }
    } else {
        warnf('<Dispatcher> Unknown event_type: %s', $type);
    }
}

sub _get_event_category {
    my ($self, $event_type) = @_;
    return Ocean::Registrar::EventCategory->get($event_type);
}

sub dispatch_node_event {
    my ($self, $event_type, $ctx, $node_id, $args, $rethrow) = @_;

    infof('<Dispatcher> @%s', $event_type);

    my $category = $self->_get_event_category($event_type);

    if ($category) {
        my $handler = $self->_get_handler($category);
        unless ($handler) {
            critf('<Dispatcher> event-handler not found for category: %s', $category);
            return;
        }
        unless ($handler->isa('Ocean::Cluster::Backend::NodeEventHandler')) {
            critf('<Dispatcher> event-handler for "%s" is not NodeEventHandler', $category);
            return;
        }
        $handler->dispatch(
            $event_type, $ctx, $node_id, $args, $rethrow);
    } else {
        warnf('<Dispatcher> unknown event_type: %s', $event_type);
    }
}

sub dispatch_worker_event {
    my ($self, $event_type, $ctx, $args, $rethrow) = @_;

    infof('<Dispatcher> @%s', $event_type);

    my $category = $self->_get_event_category($event_type);

    if ($category) {
        my $handler = $self->_get_handler($category);
        unless ($handler) {
            critf('<Dispatcher> event-handler not found for category: %s', $category);
            return;
        }
        unless ($handler->isa('Ocean::Cluster::Backend::WorkerEventHandler')) {
            critf('<Dispatcher> event-handler for "%s" is not WorkerEventHandler', $category);
            return;
        }
        $handler->dispatch(
            $event_type, $ctx, $args, $rethrow);
    } else {
        warnf('<Dispatcher> unknown event_type: %s', $event_type);
    }
}

1;
