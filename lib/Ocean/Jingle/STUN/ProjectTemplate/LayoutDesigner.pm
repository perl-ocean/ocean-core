package Ocean::Jingle::STUN::ProjectTemplate::LayoutDesigner;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::LayoutDesigner';

use Ocean::Jingle::STUN::ProjectTemplate::Layout::File::Starter;
use Ocean::Jingle::STUN::ProjectTemplate::Layout::File::Stopper;
use Ocean::Jingle::STUN::ProjectTemplate::Layout::File::Config;
use Ocean::Jingle::STUN::ProjectTemplate::Layout::File::Context;
use Ocean::ProjectTemplate::Layout::File::CertPEMExample;
use Ocean::ProjectTemplate::Layout::File::CertKeyExample;

use Ocean::ProjectTemplate::Layout::File::Scripts::DocGenerator;
use Ocean::ProjectTemplate::Layout::File::Scripts::SetupDaemonToolsService;
use Ocean::ProjectTemplate::Layout::File::Test::LoadAll;

sub design {
    my ($self, $layout, $context) = @_;

    $self->_design_root_layout( $layout, $context );
    $self->_design_certs_layout( $layout, $context );
    $self->_design_bin_layout( $layout, $context );
    $self->_design_config_layout( $layout, $context );
    $self->_design_lib_layout( $layout, $context );
    $self->_design_extlib_layout( $layout, $context );
    $self->_design_var_layout( $layout, $context );
    $self->_design_doc_layout( $layout, $context );
    $self->_design_db_layout( $layout, $context );
    $self->_design_scripts_layout( $layout, $context );
    $self->_design_asset_layout( $layout, $context );
    $self->_design_test_layout( $layout, $context );
}

sub _design_root_layout {
    my ($self, $layout, $context) = @_;

    # $layout->add_file(
    #     Ocean::Jingle::STUN::ProjectTemplate::Layout::File::Readme->new );
}

sub _design_var_layout {
    my ($self, $layout, $context) = @_;
    $layout->add_dir(q{var});
    $self->_design_log_layout( $layout );
    $self->_design_run_layout( $layout );
}

sub _design_log_layout {
    my ($self, $layout, $context) = @_;
    $layout->add_dir(q{var/log});
    $layout->register_path('log_dir' => q{var/log});
}

sub _design_run_layout {
    my ($self, $layout, $context) = @_;
    $layout->add_dir(q{var/run});
    $layout->register_path('run_dir' => q{var/run});
}


sub _design_certs_layout {
    my ($self, $layout, $context) = @_;
    my $certs_dir = $layout->add_dir(q{certs});
    my $cert_pem_file = Ocean::ProjectTemplate::Layout::File::CertPEMExample->new;
    $certs_dir->add_file( $cert_pem_file );
    $layout->register_path( cert_pem =>
        join( '/', q{certs}, $cert_pem_file->default_name ) 
    );
    my $cert_key_file = Ocean::ProjectTemplate::Layout::File::CertKeyExample->new;
    $certs_dir->add_file( $cert_key_file );
    $layout->register_path( cert_key =>
        join( '/', q{certs}, $cert_key_file->default_name ) 
    );
}

sub _design_config_layout {
    my ($self, $layout, $context) = @_;
    # template method
    my $config_dir  = $layout->add_dir(q{config});
    my $config_file = Ocean::Jingle::STUN::ProjectTemplate::Layout::File::Config->new;
    $config_dir->add_file( $config_file );

    $layout->register_path( config_dir => q{config} );
    $layout->register_path( config => 
        join( '/', q{config}, $config_file->default_name )
    );
}

sub _design_bin_layout {
    my ($self, $layout, $context) = @_;

    my $bin_dir = $layout->add_dir(q{bin});
    my $starter_file = Ocean::Jingle::STUN::ProjectTemplate::Layout::File::Starter->new;
    $bin_dir->add_file( $starter_file );
    $layout->register_path( starter_bin =>
        join( '/', q{bin}, $starter_file->default_name ) 
    );

    $bin_dir->add_file(
        Ocean::Jingle::STUN::ProjectTemplate::Layout::File::Stopper->new );
}

sub _design_lib_layout {
    my ($self, $layout, $context) = @_;

    my $lib_dir = $layout->add_dir(q{lib});
    # template method

    $self->add_module_file(
        $layout, $lib_dir, q{lib}, $context->get('context_class'), 
        Ocean::Jingle::STUN::ProjectTemplate::Layout::File::Context->new );
}

sub _design_extlib_layout {
    my ($self, $layout, $context) = @_;
    my $extlib_dir = $layout->add_dir(q{extlib});
}

sub _design_doc_layout {
    my ($self, $layout, $context) = @_;
    my $doc_dir = $layout->add_dir(q{doc});
    $layout->register_path('doc_dir' => q{doc});
}

sub _design_db_layout {
    my ($self, $layout, $context) = @_;
    # my $db_dir = $layout->add_dir(q{db});
    # $layout->register_path( db_dir => q{db});
}

sub _design_scripts_layout {
    my ($self, $layout, $context) = @_;
    my $scripts_dir = $layout->add_dir(q{scripts});
    $scripts_dir->add_file( 
        Ocean::ProjectTemplate::Layout::File::Scripts::DocGenerator->new );
    $scripts_dir->add_file( 
        Ocean::ProjectTemplate::Layout::File::Scripts::SetupDaemonToolsService->new );
}

sub _design_asset_layout {
    my ($self, $layout, $context) = @_;
    # my $asset_dir = $layout->add_dir(q{asset});
}

sub _design_test_layout {
    my ($self, $layout, $context) = @_;
    my $test_dir = $layout->add_dir(q{t});
    $test_dir->add_file(
        Ocean::ProjectTemplate::Layout::File::Test::LoadAll->new );
}

1;
