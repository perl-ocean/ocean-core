package Ocean::Logger::Spy;

use strict;
use warnings;

use parent 'Ocean::Logger';

sub initialize {
    my $self = shift;
    $self->{_records} = [];
}

sub print {
    my ($self, $time, $type, $message, $trace) = @_;
    push(@{ $self->{_records} }, 
        $self->{_formatter}->format($time, $type, $message, $trace));
}

sub clear {
    my $self = shift;
    $self->{_records} = [];
}

sub get {
    my ($self, $idx) = @_;
    return $self->{_records}[$idx];
}

sub count {
    my $self = shift;
    scalar(@{ $self->{_records} });
}

1;
