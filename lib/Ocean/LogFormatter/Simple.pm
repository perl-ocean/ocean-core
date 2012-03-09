package Ocean::LogFormatter::Simple;

use strict;
use warnings;

use parent 'Ocean::LogFormatter';

sub format {
    my ($self, $time, $type, $message, $trace) = @_;
    return $message;
}

1;
