package Ocean::Jingle::STUN::MessageBuilderContext;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw(class method transaction_id));

1;
