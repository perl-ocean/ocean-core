package Ocean::Logger::Warn;

use strict;
use warnings;

use parent 'Ocean::Logger';

sub print {
    my ($self, $time, $type, $message, $trace) = @_;
    warn $self->{_formatter}->format($time, $type, $message, $trace);
}

1;
