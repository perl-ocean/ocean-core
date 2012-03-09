package Ocean::Cluster::Frontend::Router::Route;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw(broker queue));

1;
