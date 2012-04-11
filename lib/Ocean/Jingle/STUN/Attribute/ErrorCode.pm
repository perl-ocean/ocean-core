package Ocean::Jingle::STUN::Attribute::ErrorCode;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(ERROR_CODE);

sub type   { ERROR_CODE           }
sub code   { $_[0]->get('code')   }
sub reason { $_[0]->get('reason') }

1;
