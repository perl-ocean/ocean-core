package Ocean::Cluster::Backend::ServiceComponentFactory;

use strict;
use warnings;

use Ocean::Error;
use Ocean::Cluster::Backend::EventDispatcher;
use Ocean::Cluster::Backend::ProcessManager::Single;
use Ocean::Cluster::Backend::ProcessManager::Parallel;
use Ocean::Cluster::SerializerFactory;

sub new { bless {}, $_[0] }

sub create_process_manager {
    my $self = shift;
    my $max_workers = Ocean::Config->instance->get(worker => q{max_workers});
    Ocean::Cluster::Backend::ProcessManager::Parallel->new(
          max_workers => $max_workers);
    #return ($max_workers > 1) 
    #    ? Ocean::Cluster::Backend::ProcessManager::Parallel->new(
    #            max_workers => $max_workers)
    #    : Ocean::Cluster::Backend::ProcessManager::Single->new;
}

sub create_fetcher {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Cluster::Backend::ServiceComponentFactory::create_fetcher}, 
    );
}

sub create_deliverer {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Cluster::Backend::ServiceComponentFactory::create_deliverer}, 
    );
}

sub create_serializer {
    my $self = shift;
    my $type = Ocean::Config->instance->get(worker => q{serializer}) || 'json';
    return Ocean::Cluster::SerializerFactory->create($type);
}

sub create_context {
    my $self = shift;
    my $context_class = Ocean::Config->instance->get(worker => 'context_class')
        || 'Ocean::Cluster::Backend::Context';
    
    Module::Load::load($context_class);

    my $context = $context_class->new;
    unless ($context && $context->isa('Ocean::Cluster::Backend::Context')) {
        # TODO better error handling
        die "Context Class is not a subclass of Ocean::Context";
    }
    return $context;
}

sub create_event_dispatcher {
    my $self = shift;

    my $dispatcher = Ocean::Cluster::Backend::EventDispatcher->new;

    my $handlers = Ocean::Config->instance->get('event_handler');

    for my $category ( keys %$handlers ) {

        my $handler_class = $handlers->{$category};

        Module::Load::load($handler_class);

        my $handler = $handler_class->new;
        $dispatcher->register_handler($category, $handler);
    }
    return $dispatcher;
}

1;
