package Ocean::StreamBuilder;

use strict;
use warnings;

use Ocean::Error;
use Ocean::Stream;
use Ocean::StreamComponent::IO;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _client_id        => undef,
        _client_socket    => undef,
        _io               => undef,
        _initial_protocol => undef,
    }, $class;
    return $self;
}

sub client_id {
    my ($self, $client_id) = @_;
    $self->{_client_id} = $client_id;
    return $self;
}

sub client_socket {
    my ($self, $client_socket) = @_;
    $self->{_client_socket} = $client_socket;
    return $self;
}

sub io {
    my ($self, $io) = @_;
    $self->{_io} = $io;
    return $self;
}

sub initial_protocol {
    my ($self, $initial_protocol) = @_;
    $self->{_initial_protocol} = $initial_protocol;
    return $self;
}

sub build {
    my $self = shift;

    my %components;

    Ocean::Error::ParamNotFound->throw(
        message => q{'client_id' not found}, 
    ) unless exists $self->{_client_id};

    $components{id} = $self->{_client_id};

    Ocean::Error::ParamNotFound->throw(
        message => q{'initial_protocol' not found}, 
    ) unless exists $self->{_initial_protocol};

    $components{initial_protocol} = $self->{_initial_protocol};

    Ocean::Error::ParamNotFound->throw(
        message => q{'io' not found}, 
    ) unless exists $self->{_io};

    $components{id} = $self->{_io};

    return Ocean::Stream->new(%components);
}

1;
