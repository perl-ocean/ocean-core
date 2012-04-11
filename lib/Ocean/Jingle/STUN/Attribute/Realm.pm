package Ocean::Jingle::STUN::Attribute::Realm;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(REALM);

sub type  { REALM               }
sub realm { $_[0]->get('realm') }

1;
