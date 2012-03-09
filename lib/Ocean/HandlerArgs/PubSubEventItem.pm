package Ocean::HandlerArgs::PubSubEventItem;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw(
    id
    name
    namespace
    fields
));

1;
