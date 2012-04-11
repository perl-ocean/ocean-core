package Ocean::Jingle::STUN::Entity;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw(protocol host port));

1;
