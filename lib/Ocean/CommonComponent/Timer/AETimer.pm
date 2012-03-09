package Ocean::CommonComponent::Timer::AETimer;

use strict;
use warnings;

use parent 'Ocean::CommonComponent::Timer';

use AnyEvent;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _interval => $args{inverval} || 60,
        _after    => $args{after}    ||  0,
        _delegate => undef, 
        _timer    => undef,
    }, $class;
}

sub release {
    my $self = shift;
    delete $self->{_timer}
        if $self->{_timer};
    delete $self->{_delegate}
        if $self->{_delegate};
}

sub DESTROY {
    my $self = shift;
    $self->release();
}

sub start {
    my $self = shift;
    $self->{_timer} = 
        AE::timer $self->{_after}, 
            $self->{_interval}, 
            sub {
                $self->{_delegate}->on_timer();
            };
}

sub stop {
    my $self = shift;
    delete $self->{_timer}
        if $self->{_timer};
}

1;
