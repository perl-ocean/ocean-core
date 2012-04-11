package Ocean::Jingle::STUN::Attribute::Software;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(SOFTWARE);

sub type     { SOFTWARE               }
sub software { $_[0]->get('software') }

1;
