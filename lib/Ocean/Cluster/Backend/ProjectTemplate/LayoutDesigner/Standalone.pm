package Ocean::Cluster::Backend::ProjectTemplate::LayoutDesigner::Standalone;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::ProjectTemplate::LayoutDesigner';

use Ocean::ProjectTemplate::Layout::File::Config::Fixture;

use Ocean::ProjectTemplate::Layout::File::Image::Example1;
use Ocean::ProjectTemplate::Layout::File::Image::Example2;
use Ocean::ProjectTemplate::Layout::File::Image::Example3;
use Ocean::ProjectTemplate::Layout::File::Image::Example4;
use Ocean::ProjectTemplate::Layout::File::Image::Example5;
use Ocean::ProjectTemplate::Layout::File::Image::Example6;
use Ocean::ProjectTemplate::Layout::File::Image::Example7;
use Ocean::ProjectTemplate::Layout::File::Image::Example8;

use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Config::Standalone;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Context::Standalone;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::Node;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::Authen;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::Connection;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::Message;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::People;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::Room;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::P2P;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::Worker;
use Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::PubSub;

sub _design_config_layout {
    my ($self, $layout, $context) = @_;

    my $config_dir  = $layout->add_dir(q{config});
    my $config_file = Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Config::Standalone->new;
    $config_dir->add_file( $config_file );

    my $fixture_file = Ocean::ProjectTemplate::Layout::File::Config::Fixture->new;
    $config_dir->add_file( $fixture_file );

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
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Context::Standalone->new );

    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Node'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::Node->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Authen'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::Authen->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Connection'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::Connection->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Message'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::Message->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'People'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::People->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Room'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::Room->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'P2P'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::P2P->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'Worker'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::Worker->new );
    $self->add_module_file(
        $layout, $lib_dir, q{lib}, join('::', $context->get('handler_class'), 'PubSub'), 
        Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::PubSub->new );
}

sub _design_asset_layout {
    my ($self, $layout, $context) = @_;
    my $image_dir = $layout->add_dir(q{asset/img});

    my $img_file_01 = Ocean::ProjectTemplate::Layout::File::Image::Example1->new;
    $image_dir->add_file($img_file_01);
    $layout->register_path( img_example01 => 
        join('/', q{asset/img}, $img_file_01->default_name) );

    my $img_file_02 = Ocean::ProjectTemplate::Layout::File::Image::Example2->new;
    $image_dir->add_file($img_file_02);
    $layout->register_path( img_example02 => 
        join('/', q{asset/img}, $img_file_02->default_name) );

    my $img_file_03 = Ocean::ProjectTemplate::Layout::File::Image::Example3->new;
    $image_dir->add_file($img_file_03);
    $layout->register_path( img_example03 => 
        join('/', q{asset/img}, $img_file_03->default_name) );

    my $img_file_04 = Ocean::ProjectTemplate::Layout::File::Image::Example4->new;
    $image_dir->add_file($img_file_04);
    $layout->register_path( img_example04 => 
        join('/', q{asset/img}, $img_file_04->default_name) );

    my $img_file_05 = Ocean::ProjectTemplate::Layout::File::Image::Example5->new;
    $image_dir->add_file($img_file_05);
    $layout->register_path( img_example05 => 
        join('/', q{asset/img}, $img_file_05->default_name) );

    my $img_file_06 = Ocean::ProjectTemplate::Layout::File::Image::Example6->new;
    $image_dir->add_file($img_file_06);
    $layout->register_path( img_example06 => 
        join('/', q{asset/img}, $img_file_06->default_name) );

    my $img_file_07 = Ocean::ProjectTemplate::Layout::File::Image::Example7->new;
    $image_dir->add_file($img_file_07);
    $layout->register_path( img_example07 => 
        join('/', q{asset/img}, $img_file_07->default_name) );

    my $img_file_08 = Ocean::ProjectTemplate::Layout::File::Image::Example8->new;
    $image_dir->add_file($img_file_08);
    $layout->register_path( img_example08 => 
        join('/', q{asset/img}, $img_file_08->default_name) );
}


1;
