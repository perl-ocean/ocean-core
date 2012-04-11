package Ocean::Jingle::ICE::Attribute::ICEControlling;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(ICE_CONTROLLING);

sub type  { ICE_CONTROLLING }
sub value { $_[0]->get('value') }

1;
