package Ocean::Logger::Print;

use strict;
use warnings;

use parent 'Ocean::Logger';

sub print {
    my ($self, $time, $type, $message, $trace) = @_;
    print $self->{_formatter}->format($time, $type, $message, $trace);
}

1;
