package Ocean::Jingle::TURN::Attribute::DontFragment;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(DONT_FRAGMENT);

sub type { DONT_FRAGMENT }

1;
