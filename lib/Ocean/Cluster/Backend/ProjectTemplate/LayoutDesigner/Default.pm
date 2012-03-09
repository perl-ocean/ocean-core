package Ocean::Cluster::Backend::ProjectTemplate::LayoutDesigner::Default;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::ProjectTemplate::LayoutDesigner';

use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Config::Default;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Context::Default;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::Node;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::Authen;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::Connection;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::Message;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::People;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::Room;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::P2P;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::Worker;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::PubSub;

sub _design_config_layout {
    my ($self, $layout, $context) = @_;

    my $config_dir  = $layout->add_dir(q{config});
    my $config_file = Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Config::Default->new;
    $config_dir->add_file( $config_file );

    $layout->register_path( config => 
        join( '/', q{config}, $config_file->default_name )
    );
}

sub _design_lib_layout {
    my ($self, $layout, $context) = @_;

    my $lib_dir = $layout->add_dir(q{lib});

    $self->add_module_file(
        $layout, $lib_dir, q{lib}, $context->get('context_class'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Context::Default->new );

    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Node'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::Node->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Authen'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::Authen->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Connection'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::Connection->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Message'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::Message->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'People'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::People->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Room'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::Room->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'P2P'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::P2P->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Worker'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::Worker->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'PubSub'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::PubSub->new );
}

1;
