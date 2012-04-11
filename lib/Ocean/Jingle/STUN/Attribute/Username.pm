package Ocean::Jingle::STUN::Attribute::Username;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(USERNAME);

sub type     { USERNAME               }
sub username { $_[0]->get('username') }

1;
