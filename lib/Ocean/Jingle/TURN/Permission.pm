package Ocean::Jingle::TURN::Permission;

use strict;
use warnings;

use AnyEvent;

use constant DEFAULT_LIFETIME => 3600 * 5;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _ip_address => $args{ip_address},
        _lifetime   => $args{lifetime} || DEFAULT_LIFETIME,
        _timer      => undef,
        _delegate   => undef,
    }, $class;
    return $self;
}

sub set_delegate {
    my ($self, $allocation) = @_;
    $self->{_delegate} = $allocation;
}

sub refresh {
    my ($self, $lifetime) = @_;
    $self->stop_timer();
    $self->start_timer($lifetime);
}

sub start_timer {
    my ($self, $lifetime) = @_;
    $lifetime ||= $self->{_lifetime};
    $self->{_timer} = AE::timer $lifetime, 0, sub {
        $self->on_timeout();
    };
}

sub stop_timer {
    my $self = shift;
    delete $self->{_timer};
}

sub on_timeout {
    my $self = shift;
    $self->{_delegate}->on_permission_timeout(
        $self->{_ip_address});
}

sub release {
    my $self = shift;
    delete $self->{_delegate}
        if $self->{_delegate};
    delete $self->{_timer}
        if $self->{_timer};
}

sub DESTROY {
    my $self = shift;
    $self->release();
}

1;
