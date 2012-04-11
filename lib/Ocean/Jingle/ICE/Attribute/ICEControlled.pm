package Ocean::Jingle::ICE::Attribute::ICEControlled;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(ICE_CONTROLLED);

sub type  { ICE_CONTROLLED }
sub value { $_[0]->get('value') }

1;
