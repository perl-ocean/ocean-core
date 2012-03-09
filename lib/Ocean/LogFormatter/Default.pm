package Ocean::LogFormatter::Default;

use strict;
use warnings;

use parent 'Ocean::LogFormatter';

sub format {
    my ($self, $time, $type, $message, $trace) = @_;
    return "$time [$type] $message\n";
}

1;
