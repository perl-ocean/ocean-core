package Ocean::Jingle::STUN::Attribute::AlternateServer;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute::Address';
use Ocean::Jingle::STUN::AttributeType qw(ALTERNATE_SERVER);

sub type { ALTERNATE_SERVER }

1;
