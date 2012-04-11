package Ocean::Jingle::STUN::Bootstrap;

use strict;
use warnings;

use parent 'Ocean::Bootstrap';

use Ocean::Jingle::STUN::Config::Schema;
use Ocean::Jingle::STUN::ServerFactory;

sub config_schema  { Ocean::Jingle::STUN::Config::Schema->config }
sub server_factory { Ocean::Jingle::STUN::ServerFactory->new     }

1;
