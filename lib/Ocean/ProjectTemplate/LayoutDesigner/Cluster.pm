package Ocean::ProjectTemplate::LayoutDesigner::Cluster;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::LayoutDesigner::Base';

use Ocean::ProjectTemplate::Layout::File::Config::Cluster;
use Ocean::ProjectTemplate::Layout::File::Config::Router;

use Ocean::ProjectTemplate::Layout::File::Context::Cluster;
use Ocean::ProjectTemplate::Layout::File::Handler::Cluster::Node;
use Ocean::ProjectTemplate::Layout::File::Handler::Cluster::Authen;
use Ocean::ProjectTemplate::Layout::File::Handler::Cluster::Connection;
use Ocean::ProjectTemplate::Layout::File::Handler::Cluster::Message;
use Ocean::ProjectTemplate::Layout::File::Handler::Cluster::People;
use Ocean::ProjectTemplate::Layout::File::Handler::Cluster::Room;
use Ocean::ProjectTemplate::Layout::File::Handler::Cluster::P2P;

sub _design_config_layout {
    my ($self, $layout, $context) = @_;

    my $config_dir = $layout->add_dir(q{config});
    $layout->register_path( config_dir => q{config} );

    my $config_file = Ocean::ProjectTemplate::Layout::File::Config::Cluster->new;
    $config_dir->add_file( $config_file );
    $layout->register_path( config => 
        join( '/', q{config}, $config_file->default_name )
    );

    my $router_file = Ocean::ProjectTemplate::Layout::File::Config::Router->new;
    $config_dir->add_file( $router_file );
    $layout->register_path( router => 
        join( '/', q{config}, $router_file->default_name )
    );
}

sub _design_lib_layout {
    my ($self, $layout, $context) = @_;

    my $lib_dir = $layout->add_dir(q{lib});

    $self->add_module_file(
        $layout, $lib_dir, q{lib}, $context->get('context_class'), 
        Ocean::ProjectTemplate::Layout::File::Context::Cluster->new );

    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Node'), 
        Ocean::ProjectTemplate::Layout::File::Handler::Cluster::Node->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Authen'), 
        Ocean::ProjectTemplate::Layout::File::Handler::Cluster::Authen->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Connection'), 
        Ocean::ProjectTemplate::Layout::File::Handler::Cluster::Connection->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Message'), 
        Ocean::ProjectTemplate::Layout::File::Handler::Cluster::Message->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'People'), 
        Ocean::ProjectTemplate::Layout::File::Handler::Cluster::People->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Room'), 
        Ocean::ProjectTemplate::Layout::File::Handler::Cluster::Room->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'P2P'), 
        Ocean::ProjectTemplate::Layout::File::Handler::Cluster::P2P->new );
}

1;
