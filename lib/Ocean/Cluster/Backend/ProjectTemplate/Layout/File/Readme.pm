package Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Readme;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'README' }

1;
__DATA__

** EDIT CONF

vi conf/ocean-cluster.yml

