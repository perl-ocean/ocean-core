package Ocean::Cluster::Backend::ServiceFactory;

use strict;
use warnings;

use Ocean::Cluster::Backend::ServiceBuilder;
use Ocean::Cluster::Backend::ServiceComponentFactory::Gearman;

sub new { bless {}, $_[0] }

sub create_server {
    my ($self, $config) = @_;

    my $component_factory = 
        $self->_create_service_component_factory();
    
    my $builder = Ocean::Cluster::Backend::ServiceBuilder->new;

    $builder->event_dispatcher(
        $component_factory->create_event_dispatcher($config));

    $builder->context(
        $component_factory->create_context($config));

    $builder->process_manager(
        $component_factory->create_process_manager($config));

    $builder->fetcher(
        $component_factory->create_fetcher($config));

    $builder->deliverer(
        $component_factory->create_deliverer($config));

    $builder->serializer(
        $component_factory->create_serializer($config));

    return $builder->build();
}

sub _create_service_component_factory {
    my $self = shift;
    # TODO make this configurable
    my $factory = Ocean::Cluster::Backend::ServiceComponentFactory::Gearman->new;
    return $factory;
}

1;
