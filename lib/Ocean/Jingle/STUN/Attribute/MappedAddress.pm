package Ocean::Jingle::STUN::Attribute::MappedAddress;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute::Address';
use Ocean::Jingle::STUN::AttributeType qw(MAPPED_ADDRESS);

sub type   { MAPPED_ADDRESS }

1;
