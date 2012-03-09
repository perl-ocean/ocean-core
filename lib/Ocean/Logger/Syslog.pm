package Ocean::Logger::Syslog;

use strict;
use warnings;

use parent 'Ocean::Logger';
use Sys::Syslog;

sub initialize {
    my $self = shift;

    Sys::Syslog::setlogsock 'unix'
        if $self->config('unixdomain');

    Sys::Syslog::openlog(
        $self->config('tag') || 'ocean', 
        'ndelay,pid', 
        $self->config('facility') || 'local0',
    );
}

sub print {
    my ($self, $time, $type, $message, $trace) = @_;
    Sys::Syslog::syslog(lc $type, 
        $self->{_formatter}->format($time, $type, $message, $trace));
}

sub finalize {
    my $self = shift;
    Sys::Syslog::closelog();
}

1;
