package Ocean::Jingle::TURN::Attribute::ReservationToken;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(RESERVATION_TOKEN);

sub type  { RESERVATION_TOKEN   }
sub token { $_[0]->get('token') }

1;
