package Ocean::Jingle::TURN::Attribute::EvenPort;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(EVEN_PORT);

sub type { EVEN_PORT       }
sub R    { $_[0]->get('R') }

1;
