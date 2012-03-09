package Ocean::ProjectTemplate::Layout::File::Scripts::SetupDaemonToolsService;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::ExecutableFile';

sub template     { do { local $/; <DATA> } }
sub default_name { 'setup_daemontools' }

1;

__DATA__
#!/usr/bin/env perl

eval 'exec /usr/bin/perl -w -S $0 ${1+"$@"}' if 0;

use strict;
use warnings;

use FindBin;
use File::Spec ();

use Ocean::ProjectTemplate::Shell::DaemonToolsHelper;
use Ocean::ProjectTemplate::Dumper;
use Ocean::ProjectTemplate::DiskIO::Default;
use Ocean::ProjectTemplate::Display::Default;
use Ocean::ProjectTemplate::Renderer::Xslate;
use Ocean::ProjectTemplate::Messages::DaemonToolsHelper;
use Ocean::ProjectTemplate::LayoutDesigner::DaemonToolsHelper;

my $disk_io  = Ocean::ProjectTemplate::DiskIO::Default->new;
my $display  = Ocean::ProjectTemplate::Display::Default->new;
my $renderer = Ocean::ProjectTemplate::Renderer::Xslate->new;
my $messages = Ocean::ProjectTemplate::Messages::DaemonToolsHelper->new;

my $designer = Ocean::ProjectTemplate::LayoutDesigner::DaemonToolsHelper->new;

my $dumper = Ocean::ProjectTemplate::Dumper->new(
    disk_io  => $disk_io,
    display  => $display,
    renderer => $renderer,
);

my $shell = Ocean::ProjectTemplate::Shell::DaemonToolsHelper->new(
    dumper          => $dumper,
    renderer        => $renderer,
    display         => $display,
    messages        => $messages,
    layout_designer => $designer,
);

$shell->run_at( $FindBin::RealBin );

