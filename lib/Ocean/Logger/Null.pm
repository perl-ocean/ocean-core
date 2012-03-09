package Ocean::Logger::Null;

use strict;
use warnings;

use parent 'Ocean::Logger';

sub print {
    my ($self, $time, $type, $message, $trace) = @_;
    # do nothing
}

1;


