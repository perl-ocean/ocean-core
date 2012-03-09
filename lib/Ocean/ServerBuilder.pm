package Ocean::ServerBuilder;

use strict;
use warnings;

use Ocean::Server;
use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _event_dispatcher => undef, 
        _stream_manager   => undef, 
        _stream_factory   => undef, 
        _listener         => undef,
        _daemonizer       => undef,
        _signal_handler   => undef,
        _timer            => undef,
        _context          => undef,
    }, $class;
    return $self;
}

sub context {
    my ($self, $context) = @_;
    $self->{_context} = $context;
    return $self;
}

sub event_dispatcher {
    my ($self, $event_dispatcher) = @_;
    $self->{_event_dispatcher} = $event_dispatcher;
    return $self;
}

sub stream_manager {
    my ($self, $stream_manager) = @_;
    $self->{_stream_manager} = $stream_manager;
    return $self;
}

sub stream_factory {
    my ($self, $stream_factory) = @_;
    $self->{_stream_factory} = $stream_factory;
    return $self;
}

sub listener {
    my ($self, $listener) = @_;
    $self->{_listener} = $listener;
    return $self;
}

sub daemonizer {
    my ($self, $daemonizer) = @_;
    $self->{_daemonizer} = $daemonizer;
    return $self;
}

sub signal_handler {
    my ($self, $signal_handler) = @_;
    $self->{_signal_handler} = $signal_handler;
    return $self;
}

sub timer {
    my ($self, $timer) = @_;
    $self->{_timer} = $timer;
    return $self;
}

sub build {
    my $self = shift;

    my %components;

    Ocean::Error::ParamNotFound->throw(
        message => q{'context' not found}, 
    ) unless exists $self->{_context};

    $components{context} = $self->{_context};

    Ocean::Error::ParamNotFound->throw(
        message => q{'event_dispatcher' not found}, 
    ) unless exists $self->{_event_dispatcher};

    $components{event_dispatcher} = $self->{_event_dispatcher};

    Ocean::Error::ParamNotFound->throw(
        message => q{'stream_manager' not found}, 
    ) unless exists $self->{_stream_manager};

    $components{stream_manager} = $self->{_stream_manager};

    Ocean::Error::ParamNotFound->throw(
        message => q{'stream_factory' not found}, 
    ) unless exists $self->{_stream_factory};

    $components{stream_factory} = $self->{_stream_factory};

    Ocean::Error::ParamNotFound->throw(
        message => q{'listener' not found}, 
    ) unless exists $self->{_listener};

    $components{listener} = $self->{_listener};

    Ocean::Error::ParamNotFound->throw(
        message => q{'daemonizer' not found}, 
    ) unless exists $self->{_daemonizer};

    $components{daemonizer} = $self->{_daemonizer};

    Ocean::Error::ParamNotFound->throw(
        message => q{'signal_handler' not found}, 
    ) unless exists $self->{_signal_handler};

    $components{signal_handler} = $self->{_signal_handler};

    Ocean::Error::ParamNotFound->throw(
        message => q{'timer' not found}, 
    ) unless exists $self->{_timer};

    $components{timer} = $self->{_timer};

    return Ocean::Server->new(%components);
}

1;

