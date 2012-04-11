package Ocean::Jingle::TURN::Attribute::Data;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(DATA);

sub type { DATA               }
sub data { $_[0]->get('data') }

1;
