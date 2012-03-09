package Ocean::HandlerArgs::SASLAuthRequest;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw(
    stream_id    
    mechanism
    text
));

1;
