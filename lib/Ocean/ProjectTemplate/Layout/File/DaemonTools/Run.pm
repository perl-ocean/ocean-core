package Ocean::ProjectTemplate::Layout::File::DaemonTools::Run;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::ExecutableFile';

sub template     { do { local $/; <DATA> } }
sub default_name { 'run'            }

1;

__DATA__
#!/bin/sh
exec 2>&1
exec setuidgid <: $context.get('account_name') :> <: $layout.absolute_path_for('starter_bin') :>
