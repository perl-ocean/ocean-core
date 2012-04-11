package Ocean::Jingle::TURN::Attribute::RequestedTransport;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(REQUESTED_TRANSPORT);

sub type { REQUESTED_TRANSPORT }

1;
