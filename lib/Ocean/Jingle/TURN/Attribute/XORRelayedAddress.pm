package Ocean::Jingle::TURN::Attribute::XORRelayedAddress;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute::Address';
use Ocean::Jingle::STUN::AttributeType qw(XOR_RELAYED_ADDRESS);

sub type { XOR_RELAYED_ADDRESS }

1;
