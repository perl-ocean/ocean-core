package Ocean::Jingle::TURN::Attribute::ChannelNumber;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(CHANNEL_NUMBER);

sub type   { CHANNEL_NUMBER       }
sub number { $_[0]->get('number') }

1;
