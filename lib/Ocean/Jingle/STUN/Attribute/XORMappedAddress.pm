package Ocean::Jingle::STUN::Attribute::XORMappedAddress;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute::Address';
use Ocean::Jingle::STUN::AttributeType qw(XOR_MAPPED_ADDRESS);

sub type { XOR_MAPPED_ADDRESS }

1;
