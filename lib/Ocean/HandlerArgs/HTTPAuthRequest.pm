package Ocean::HandlerArgs::HTTPAuthRequest;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw(
    stream_id    
    cookie
    domain
    origin
    query_params
));

1;
