package Ocean::Jingle::TURN::Attribute::Lifetime;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(LIFETIME);

sub type     { LIFETIME               }
sub lifetime { $_[0]->get('lifetime') }

1;
