package Ocean::Stanza::DeliveryRequest::DiscoInfoIdentity;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw(
    category
    type
    name
));

1;
