package Ocean::Stanza::DeliveryRequest::SASLAuthFailure;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw(
    stream_id    
));

1;
