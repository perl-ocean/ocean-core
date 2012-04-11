package Ocean::Jingle::STUN::ServerComponent::TCPListener::AESocket::TLS;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::ServerComponent::TCPListener::AESocket';

use Ocean::Config;
use Ocean::Error;
use Ocean::Util::TLS;

use AnyEvent::Handle;

sub create_handle {
    my ($self, $sock) = @_;

    Ocean::Error->throw(
        message => '"tls" section not found in configuration',
    ) unless Ocean::Config->instance->has_section('tls');

    my %params = (
        fh       => $sock, 
        autocork => 1,
        no_delay => 1,
        rbuf_max => $self->{_max_read_buffer},
        timeout  => $self->{_timeout},
        tls      => 'accept',
        tls_ctx  => Ocean::Config->instance->get('tls'),
    );

    return AnyEvent::Handle->new(%params);
}

1;
