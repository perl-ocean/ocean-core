package Ocean::Jingle::TURN::RelayedTransportAddressSocket;

use strict;
use warnings;

use AnyEvent::Handle::UDP;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _ip_address => undef,
        _port       => undef,
        _handle     => undef,
    }, $class;
    return $self;
}

sub start {
    my $self = shift;
    $self->{_handle} = AnyEvent::Handle::UDP->new(
        bind => [$self->{_ip_address}, $self->{_port}], 
    );
    $self->{_handle}->on_recv();
    $self->{_handle}->on_error();
}

1;
