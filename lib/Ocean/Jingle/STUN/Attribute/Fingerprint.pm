package Ocean::Jingle::STUN::Attribute::Fingerprint;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(FINGERPRINT);

sub type   { FINGERPRINT          } 
sub crc    { $_[0]->get('crc')    }
sub target { $_[0]->get('target') }

1;
