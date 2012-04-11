package Ocean::Jingle::STUN::Attribute::Address;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Error;

sub address { $_[0]->get('address') }
sub port    { $_[0]->get('port')    }
sub family  { $_[0]->get('family')  }

1;
