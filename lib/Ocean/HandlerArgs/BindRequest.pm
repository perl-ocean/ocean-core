package Ocean::HandlerArgs::BindRequest;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw(
    stream_id    
    user_id
    resource
    want_extval
));

1;
