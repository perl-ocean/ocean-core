package Ocean::ProjectTemplate::Layout::File::Readme;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { local $/; <DATA> }
sub default_name { 'README'         }

1;

__DATA__
** EDIT CONF

vi conf/ocean.yml

** CHANGE LIMIT OF FILE DISCRIPTOR

ulimit

or 

vi /etc/security/limits.conf
user1 soft nofile 300000
user1 hard nofile 300000

