package Ocean::ServerFactory;

use strict;
use warnings;

use Module::Load ();
use Log::Minimal;
use Ocean::ServerBuilder;

sub new { bless {}, $_[0] }

sub create_server {
    my ($self, $config, $daemonize) = @_;

    my $type = $config->get(server => q{type});

    my $component_factory = 
        $self->_create_server_component_factory($type);

    return unless $component_factory;

    my $builder = Ocean::ServerBuilder->new;

    $builder->context(
        $component_factory->create_context($config));

    $builder->event_dispatcher(
        $component_factory->create_event_dispatcher($config));

    $builder->stream_manager(
        $component_factory->create_stream_manager($config));

    $builder->stream_factory(
        $component_factory->create_stream_factory($config));

    $builder->listener(
        $component_factory->create_listener($config));

    $builder->daemonizer(
        $component_factory->create_daemonizer($config, $daemonize));

    $builder->signal_handler(
        $component_factory->create_signal_handler($config));

    $builder->timer(
        $component_factory->create_timer($config));

    return $builder->build();
}

my %COMPONENT_FACTORY_MAP = (
    'xmpp'           => 'Ocean::ServerComponentFactory::Default',
    'websocket'      => 'Ocean::ServerComponentFactory::WebSocket',
    'http-websocket' => 'Ocean::ServerComponentFactory::HTTPBinding::WebSocket',
    'http-sse'       => 'Ocean::ServerComponentFactory::HTTPBinding::SSE',
    'http-xhr'       => 'Ocean::ServerComponentFactory::HTTPBinding::XHR',
);

sub _create_server_component_factory {
    my ($self, $type) = @_;
    my $factory_class = $COMPONENT_FACTORY_MAP{ $type };
    unless ($factory_class) {
        critf("<Server> unknown server-type '%s' was indicated", $type);
        return;
    }
    Module::Load::load($factory_class);
    return $factory_class->new;
}


1;
