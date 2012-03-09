package Ocean::Logger::File;

use strict;
use warnings;

use parent 'Ocean::Logger';
use Log::Dispatch::FileRotate;

sub initialize {
    my $self = shift;
    my %option = (
        min_level => $self->config('level'),
        filename  => $self->config('filepath'),
        mode      => 'append',
    );
    if ($self->config('size')) {
        $option{size} = $self->config('size');
    } else {
        $option{DatePattern} = $self->config('date_pattern') || 'yyyy-MM-dd';
        $option{TZ} = $self->config('tz') if $self->config('tz');
    }
    $self->{_dispatcher} = Log::Dispatch::FileRotate->new(%option);
}

sub print {
    my ($self, $time, $type, $message, $trace) = @_;
    $self->{_dispatcher}->log(
        level   => lc $type,
        message => $self->{_formatter}->format($time, $type, $message, $trace),
    );
}

1;
