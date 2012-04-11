package Ocean::Jingle::STUN::ServerFactory;

use strict;
use warnings;

use Ocean::Jingle::STUN::ServerBuilder;
use Ocean::Jingle::STUN::ServerComponentFactory;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
    
    }, $class;
    return $self;
}

sub create_server {
    my ($self, $config, $daemonize) = @_;

    my $component_factory =
        $self->_create_server_component_factory();

    my $builder = Ocean::Jingle::STUN::ServerBuilder->new;

    $builder->context(
        $component_factory->create_context($config));

    $builder->udp_transport(
        $component_factory->create_udp_transport($config));

    $builder->tcp_connection_manager(
        $component_factory->create_tcp_connection_manager($config));

    $builder->tcp_listener(
        $component_factory->create_tcp_listener($config));

    $builder->tcp_tls_listener(
        $component_factory->create_tcp_tls_listener($config));

    $builder->daemonizer(
        $component_factory->create_daemonizer($config, $daemonize));

    $builder->signal_handler(
        $component_factory->create_signal_handler($config));

    $builder->attribute_codec_store(
        $component_factory->create_attribute_codec_store($config));

    return $builder->build();
}

sub _create_server_component_factory {
    my $self = shift;
    return Ocean::Jingle::STUN::ServerComponentFactory->new;
}

1;
