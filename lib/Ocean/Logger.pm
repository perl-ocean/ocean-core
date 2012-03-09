package Ocean::Logger;

use strict;
use warnings;

use Ocean::Error;

sub new { 
    my ($class, %args) = @_;
    my $self = bless {
        _config    => $args{config}, 
        _formatter => $args{formatter},
    }, $class;
    return $self;
}

sub config {
    my ($self, $field) = @_;
    return $self->{_config}->get(log => $field);
}

sub initialize {
    my $self = shift;
    # template method
}

sub print {
    my ($self, $time, $type, $message, $trace) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Logger::print}, 
    );
}

sub finalize {
    my $self = shift;
    # template method
}

1;
