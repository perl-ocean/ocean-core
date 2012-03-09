package Ocean::ProjectTemplate::LayoutDesigner::Default;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::LayoutDesigner::Base';

use Ocean::ProjectTemplate::Layout::File::Handler::Default::Node;
use Ocean::ProjectTemplate::Layout::File::Handler::Default::Authen;
use Ocean::ProjectTemplate::Layout::File::Handler::Default::Connection;
use Ocean::ProjectTemplate::Layout::File::Handler::Default::Message;
use Ocean::ProjectTemplate::Layout::File::Handler::Default::People;
use Ocean::ProjectTemplate::Layout::File::Handler::Default::Room;
use Ocean::ProjectTemplate::Layout::File::Handler::Default::P2P;

use Ocean::ProjectTemplate::Layout::File::Config::Default;
use Ocean::ProjectTemplate::Layout::File::Context::Default;

sub _design_config_layout {
    my ($self, $layout, $context) = @_;

    my $config_dir  = $layout->add_dir(q{config});
    my $config_file = Ocean::ProjectTemplate::Layout::File::Config::Default->new;
    $config_dir->add_file( $config_file );

    $layout->register_path( config_dir => q{config} );
    $layout->register_path( config => 
        join( '/', q{config}, $config_file->default_name )
    );
}

sub _design_lib_layout {
    my ($self, $layout, $context) = @_;

    my $lib_dir = $layout->add_dir(q{lib});

    $self->add_module_file(
        $layout, $lib_dir, q{lib}, $context->get('context_class'), 
        Ocean::ProjectTemplate::Layout::File::Context::Default->new );

    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Node'), 
        Ocean::ProjectTemplate::Layout::File::Handler::Default::Node->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Authen'), 
        Ocean::ProjectTemplate::Layout::File::Handler::Default::Authen->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Connection'), 
        Ocean::ProjectTemplate::Layout::File::Handler::Default::Connection->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Message'), 
        Ocean::ProjectTemplate::Layout::File::Handler::Default::Message->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'People'), 
        Ocean::ProjectTemplate::Layout::File::Handler::Default::People->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Room'), 
        Ocean::ProjectTemplate::Layout::File::Handler::Default::Room->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'P2P'), 
        Ocean::ProjectTemplate::Layout::File::Handler::Default::P2P->new );
}

1;
