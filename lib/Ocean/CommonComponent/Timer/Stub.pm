package Ocean::CommonComponent::Timer::Stub;

use strict;
use warnings;

use parent 'Ocean::CommonComponent::Timer';

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _delegate => undef, 
    }, $class;
}

sub release {
    my $self = shift;
    delete $self->{_delegate}
        if $self->{_delegate};
}

sub DESTROY {
    my $self = shift;
    $self->release();
}

sub start {
    my $self = shift;
    # do nothing
}

sub stop {
    my $self = shift;
    # do nothing
}

sub emulate_timer_event {
    my $self = shift;
    $self->{_delegate}->on_timer();
}

1;
