package Ocean::Jingle::STUN::ServerBuilder;

use strict;
use warnings;

use Ocean::Jingle::STUN::Server;
use Ocean::Error;

sub new { 
    my $class = shift;
    my $self = bless {
        _daemonizer             => undef,
        _signal_handler         => undef,
        _tcp_listener           => undef,
        _tcp_tls_listener       => undef,
        _udp_transport          => undef,
        _context                => undef,
        _tcp_connection_manager => undef,
        _attribute_codec_store  => undef,
    }, $class;
    return $self;
}

sub attribute_codec_store {
    my ($self, $attribute_codec_store) = @_;
    $self->{_attribute_codec_store} = $attribute_codec_store;
    return $self;
}

sub context {
    my ($self, $context) = @_;
    $self->{_context} = $context;
    return $self;
}

sub tcp_listener {
    my ($self, $tcp_listener) = @_;
    $self->{_tcp_listener} = $tcp_listener;
    return $self;
}

sub tcp_tls_listener {
    my ($self, $tcp_tls_listener) = @_;
    $self->{_tcp_tls_listener} = $tcp_tls_listener;
    return $self;
}

sub tcp_connection_manager {
    my ($self, $tcp_connection_manager) = @_;
    $self->{_tcp_connection_manager} = $tcp_connection_manager;
    return $self;
}

sub udp_transport {
    my ($self, $udp_transport) = @_;
    $self->{_udp_transport} = $udp_transport;
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

sub build {
    my $self = shift;

    my %components;

    for my $comp_name ( qw(
        signal_handler     
        daemonizer
        udp_transport
        tcp_listener
        tcp_tls_listener
        tcp_connection_manager
        context
        attribute_codec_store
    ) ) {

        my $prop = '_'.$comp_name;

        Ocean::Error::ParamNotFound->throw(
            message => sprintf(q{'%s' not found}, $comp_name)
        ) unless exists $self->{$prop};

        $components{$comp_name} = $self->{$prop};
    }

    return Ocean::Jingle::STUN::Server->new(%components);
}

1;
