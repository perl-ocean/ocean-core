package Ocean::Jingle::STUN::ServerComponent::TCPListener::AESocket::Default;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::ServerComponent::TCPListener::AESocket';

use AnyEvent::Handle;

sub create_handle {
    my ($self, $sock) = @_;

    my %params = (
        fh       => $sock, 
        autocork => 1,
        no_delay => 1,
        rbuf_max => $self->{_max_read_buffer},
        timeout  => $self->{_timeout},
    );

    return AnyEvent::Handle->new(%params);
}

1;
