package Ocean::ProjectTemplate::Layout::File::DaemonTools::Readme;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'README'         }

1;

__DATA__
** EDIT CONF

vi conf/ocean.yml

** MAKE SYMBOLIC REFERENCE FOR DAEMONTOOLS

ln -s <: $layout.absolute_path_for('daemontools_service_dir') :> /service

** CHANGE LIMIT OF FILE DISCRIPTOR

ulimit

or 

vi /etc/security/limits.conf
user1 soft nofile 300000
user1 hard nofile 300000

