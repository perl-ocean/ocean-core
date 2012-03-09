package Ocean::Cluster::Backend::Bootstrap;

use strict;
use warnings;

use parent 'Ocean::Bootstrap';

use Ocean::Cluster::Backend::Config::Schema;
use Ocean::Cluster::Backend::ServiceFactory;

sub config_schema  { Ocean::Cluster::Backend::Config::Schema->config }
sub server_factory { Ocean::Cluster::Backend::ServiceFactory->new    }

1;
