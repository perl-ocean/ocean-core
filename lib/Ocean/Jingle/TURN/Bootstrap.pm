package Ocean::Jingle::TURN::Bootstrap;

use strict;
use warnings;

use parent 'Ocean::Bootstrap';

use Ocean::Jingle::TURN::Config::Schema;
use Ocean::Jingle::TURN::ServerFactory;

sub config_schema  { Ocean::Jingle::TURN::Config::Schema->config }
sub server_factory { Ocean::Jingle::TURN::ServerFactory->new     }

1;
