package Ocean::Jingle::ICE::Attribute::UseCandidate;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(USE_CANDIDATE);

sub type { USE_CANDIDATE }

1;
