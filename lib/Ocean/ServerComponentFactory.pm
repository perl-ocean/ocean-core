package Ocean::ServerComponentFactory;

use strict;
use warnings;

use Module::Load ();

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
    my ($self, $config) = @_;
    my $context_class = $config->get(server => 'context_class')
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
    my ($self, $config) = @_;

    my $dispatcher = Ocean::EventDispatcher->new;

    my $handlers = $config->get('event_handler');

    for my $category ( keys %$handlers ) {

        my $handler_class = $handlers->{$category};

        Module::Load::load($handler_class);

        my $handler = $handler_class->new;
        $dispatcher->register_handler($category, $handler);
    }
    return $dispatcher;
}

sub create_listener {
    my ($self, $config) = @_;

    return Ocean::ServerComponent::Listener::AESocket->new(
        host            => $config->get(server => q{host}),
        port            => $config->get(server => q{port}),
        backlog         => $config->get(server => q{backlog}),
        max_read_buffer => $config->get(server => q{max_read_buffer}),
        timeout         => $config->get(server => q{timeout}),
    );
}

sub create_stream_manager {
    my ($self, $config) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ServerComponentFactory::create_stream_manager}, 
    );
}

sub create_stream_factory {
    my ($self, $config) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ServerComponentFactory::create_stream_factory}, 
    );
}

sub create_signal_handler {
    my ($self, $config) = @_;
    return Ocean::CommonComponent::SignalHandler::AESignal->new;
}

sub create_timer {
    my ($self, $config) = @_;

    my $interval = $config->get(server => 'report_interval');

    return Ocean::CommonComponent::Timer::AETimer->new(
        interval => $interval, 
        after    => $interval,
    );
}

sub create_daemonizer {
    my ($self, $config, $daemonize) = @_;

    my $pid_file = $config->get('server', 'pid_file');

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
