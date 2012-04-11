package Ocean::Jingle::TURN::Attribute::XORPeerAddress;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute::Address';
use Ocean::Jingle::STUN::AttributeType qw(XOR_PEER_ADDRESS);

sub type { XOR_PEER_ADDRESS }

1;
