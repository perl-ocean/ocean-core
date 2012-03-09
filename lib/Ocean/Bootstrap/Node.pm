package Ocean::Bootstrap::Node;

use strict;
use warnings;

use parent 'Ocean::Bootstrap';

use Ocean::Config::Schema;
use Ocean::ServerFactory;

sub config_schema  { Ocean::Config::Schema->config }
sub server_factory { Ocean::ServerFactory->new     }

1;
