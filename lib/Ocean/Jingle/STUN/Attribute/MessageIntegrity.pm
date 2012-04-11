package Ocean::Jingle::STUN::Attribute::MessageIntegrity;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(MESSAGE_INTEGRITY);

sub type   { MESSAGE_INTEGRITY    } 
sub hash   { $_[0]->get('hash')   }
sub target { $_[0]->get('target') }

1;
