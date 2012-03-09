package Ocean::HandlerArgs::NodeTimerReport;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw(
    total_connection_counter
    current_connection_counter
));

1;
