package Ocean::Jingle::STUN::Attribute::Nonce;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(NONCE);

sub type  { NONCE               }
sub nonce { $_[0]->get('nonce') }

1;
