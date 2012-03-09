package Ocean::HandlerArgs::TooManyAuthAttempt;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw(
    host
    port
));

1;
