package Ocean::ProjectTemplate::LayoutDesigner::DaemonToolsHelper;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::LayoutDesigner';

use Ocean::ProjectTemplate::Layout::File::Starter;
use Ocean::ProjectTemplate::Layout::File::DaemonTools::Run;
use Ocean::ProjectTemplate::Layout::File::DaemonTools::LogRun;

sub design {
    my ($self, $layout, $context ) = @_;
    $self->_design_asset_layout( $layout, $context );
}

sub _design_bin_layout {
    my ($self, $layout, $context) = @_;
    my $bin_dir = $layout->add_dir(q{bin});
    my $starter_file = Ocean::ProjectTemplate::Layout::File::Starter->new;
    $layout->register_path( starter_bin =>
        join( '/', q{bin}, $starter_file->default_name ) 
    );
}


sub _design_asset_layout {
    my ($self, $layout, $context) = @_;

    my $asset_dir = $layout->add_dir(q{asset});

    my $service_dir_path = sprintf q{asset/daemontools/%s}, $layout->relative_project_dir;
    my $dt_dir = $layout->add_dir( $service_dir_path );
    $layout->register_path( 'daemontools_service_dir' => $service_dir_path );

    $dt_dir->add_file( 
        Ocean::ProjectTemplate::Layout::File::DaemonTools::Run->new );

    my $dt_log_dir_path = sprintf q{asset/daemontools/%s/log}, $layout->relative_project_dir;
    my $dt_log_dir = $layout->add_dir( $dt_log_dir_path );
    $layout->register_path( 'daemontools_log_dir' => $dt_log_dir_path );

    $dt_log_dir->add_file( 
        Ocean::ProjectTemplate::Layout::File::DaemonTools::LogRun->new );

    $layout->add_dir(
        sprintf q{asset/daemontools/%s/log/main}, $layout->relative_project_dir);

}

1;
