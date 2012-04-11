package Ocean::Jingle::STUN::ServerComponentFactory;

use strict;
use warnings;

use Module::Load ();

use Ocean::Error;
use Ocean::ServerComponent::Daemonizer::Default;
use Ocean::ServerComponent::Daemonizer::Null;
use Ocean::CommonComponent::SignalHandler::AESignal;
use Ocean::Jingle::STUN::ServerComponent::TCPListener::AESocket::Default;
use Ocean::Jingle::STUN::ServerComponent::TCPListener::AESocket::TLS;
use Ocean::Jingle::STUN::ServerComponent::TCPListener::Null;
use Ocean::Jingle::STUN::ServerComponent::UDPTransport::AEHUDP;
use Ocean::Jingle::STUN::TCPConnectionManager;
use Ocean::Jingle::STUN::AttributeCodecStoreFactory::STUN;

sub new { bless {}, $_[0] }

sub create_attribute_codec_store {
    my ($self, $config) = @_;
    return Ocean::Jingle::STUN::AttributeCodecStoreFactory::STUN->create_store();
}

sub create_context {
    my ($self, $config) = @_;
    my $context_class = $config->get(server => 'context_class')
        || 'Ocean::Jingle::STUN::Context';
    
    Module::Load::load($context_class);

    my $context = $context_class->new;
    unless ($context && $context->isa('Ocean::Jingle::STUN::Context')) {
        die "Context Class is not a subclass of Ocean::Jingle::STUN::Context";
    }
    return $context;
}

sub create_signal_handler {
    my ($self, $config) = @_;
    return Ocean::CommonComponent::SignalHandler::AESignal->new;
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

sub create_tcp_listener {
    my ($self, $config) = @_;
    if ($config->has_section('tcp')) {
        return Ocean::Jingle::STUN::ServerComponent::TCPListener::AESocket::Default->new(
            host            => $config->get(server => q{host}),
            port            => $config->get(tcp    => q{port}),
            backlog         => $config->get(tcp    => q{backlog}),
            max_read_buffer => $config->get(tcp    => q{max_read_buffer}),
            timeout         => $config->get(tcp    => q{timeout}),
        );
    } else {
        return Ocean::Jingle::STUN::ServerComponent::TCPListener::Null->new;
    }
}

sub create_tcp_tls_listener {
    my ($self, $config) = @_;
    if (   $config->has_section('tcp') 
        && $config->get(tcp => q{secure_port})) {

        Ocean::Error->throw(
            message => q{'secure_port' is set, but 'tls' section not found.}, 
        ) unless $config->has_section('tls');

        return Ocean::Jingle::STUN::ServerComponent::TCPListener::AESocket::TLS->new(
            host            => $config->get(server => q{host}),
            port            => $config->get(tcp    => q{secure_port}),
            backlog         => $config->get(tcp    => q{backlog}),
            max_read_buffer => $config->get(tcp    => q{max_read_buffer}),
            timeout         => $config->get(tcp    => q{timeout}),
        );
    } else {
        return Ocean::Jingle::STUN::ServerComponent::TCPListener::Null->new;
    }
}

sub create_udp_transport {
    my ($self, $config) = @_;
    return Ocean::Jingle::STUN::ServerComponent::UDPTransport::AEHUDP->new(
        host         => $config->get(server => q{host}),
        port         => $config->get(server => q{port}),
        receive_size => $config->get(server => q{receive_size}),
    );
}

sub create_tcp_connection_manager {
    my ($self, $config) = @_;
    return Ocean::Jingle::STUN::TCPConnectionManager->new; 
}

1;
