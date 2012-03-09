package Ocean::Cluster::Backend::ServiceBuilder;

use strict;
use warnings;

use Ocean::Cluster::Backend::Service;
use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _event_dispatcher => undef,
        _fetcher          => undef,
        _deliverer        => undef,
        _serializer       => undef,
        _process_manager  => undef, 
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

sub process_manager {
    my ($self, $process_manager) = @_;
    $self->{_process_manager} = $process_manager;
    return $self;
}

sub fetcher {
    my ($self, $fetcher) = @_;
    $self->{_fetcher} = $fetcher;
    return $self;
}

sub deliverer {
    my ($self, $deliverer) = @_;
    $self->{_deliverer} = $deliverer;
    return $self;
}

sub serializer {
    my ($self, $serializer) = @_;
    $self->{_serializer} = $serializer;
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
        message => q{'process_manager' not found}, 
    ) unless exists $self->{_process_manager};

    $components{process_manager} = $self->{_process_manager};

    Ocean::Error::ParamNotFound->throw(
        message => q{'fetcher' not found}, 
    ) unless exists $self->{_fetcher};

    $components{fetcher} = $self->{_fetcher};

    Ocean::Error::ParamNotFound->throw(
        message => q{'deliverer' not found}, 
    ) unless exists $self->{_deliverer};

    $components{deliverer} = $self->{_deliverer};

    Ocean::Error::ParamNotFound->throw(
        message => q{'serializer' not found}, 
    ) unless exists $self->{_serializer};

    $components{serializer} = $self->{_serializer};

    return Ocean::Cluster::Backend::Service->new(%components);
}

1;

