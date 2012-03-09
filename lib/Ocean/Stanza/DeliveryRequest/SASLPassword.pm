package Ocean::Stanza::DeliveryRequest::SASLPassword;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw(
    stream_id
    username
    password
));

1;
