package Ocean::Jingle::ICE::Attribute::Priority;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(PRIORITY);

sub type { PRIORITY }
sub priority { $_[0]->get('priority') }

1;
