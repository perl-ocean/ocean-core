package Ocean::ServerComponentFactory;

use strict;
use warnings;

use Module::Load ();

use Ocean::Config;
use Ocean::Error;
use Ocean::Server;
use Ocean::ServerComponent::Listener::AESocket;
use Ocean::ServerComponent::Daemonizer::Default;
use Ocean::ServerComponent::Daemonizer::Null;
use Ocean::EventDispatcher;
use Ocean::CommonComponent::SignalHandler::AESignal;
use Ocean::CommonComponent::Timer::AETimer;

sub new { bless {}, $_[0] }


sub create_context {
    my $self = shift;
    my $context_class = Ocean::Config->instance->get(server => 'context_class')
        || 'Ocean::Context';
    
    Module::Load::load($context_class);

    my $context = $context_class->new;
    unless ($context && $context->isa('Ocean::Context')) {
        # TODO better error handling
        die "Context Class is not a subclass of Ocean::Context";
    }
    return $context;
}

sub create_event_dispatcher {
    my $self = shift;

    my $dispatcher = Ocean::EventDispatcher->new;

    my $handlers = Ocean::Config->instance->get('event_handler');

    for my $category ( keys %$handlers ) {

        my $handler_class = $handlers->{$category};

        Module::Load::load($handler_class);

        my $handler = $handler_class->new;
        $dispatcher->register_handler($category, $handler);
    }
    return $dispatcher;
}

sub create_listener {
    my $self = shift;

    return Ocean::ServerComponent::Listener::AESocket->new(
        host            => Ocean::Config->instance->get(server => q{host}),
        port            => Ocean::Config->instance->get(server => q{port}),
        backlog         => Ocean::Config->instance->get(server => q{backlog}),
        max_read_buffer => Ocean::Config->instance->get(server => q{max_read_buffer}),
        timeout         => Ocean::Config->instance->get(server => q{timeout}),
        timeout_preauth => Ocean::Config->instance->get(server => q{timeout_preauth}),
    );
}

sub create_stream_manager {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ServerComponentFactory::create_stream_manager}, 
    );
}

sub create_stream_factory {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ServerComponentFactory::create_stream_factory}, 
    );
}

sub create_signal_handler {
    my $self = shift;
    return Ocean::CommonComponent::SignalHandler::AESignal->new;
}

sub create_timer {
    my $self = shift;

    my $interval = Ocean::Config->instance->get(server => 'report_interval');

    return Ocean::CommonComponent::Timer::AETimer->new(
        interval => $interval, 
        after    => $interval,
    );
}

sub create_daemonizer {
    my ($self, $daemonize) = @_;

    my $pid_file = Ocean::Config->instance->get('server', 'pid_file');

    if ($daemonize && !$pid_file) {
        die "'pid_file' not found. "
            . "To daemonize process, you need to add 'pid_file' "
            . "setting on your config file.";
    }
    my $daemonizer = $daemonize
        ? Ocean::ServerComponent::Daemonizer::Default->new( pid_file => $pid_file )
        : Ocean::ServerComponent::Daemonizer::Null->new();
    return $daemonizer;
}

1;
