package Ocean::HTTPBinding::StreamFactory::SSE;

use strict;
use warnings;

use parent 'Ocean::StreamFactory';

use Ocean::Stream;
use Ocean::StreamComponent::IO;
use Ocean::StreamComponent::IO::Decoder::JSON;
use Ocean::StreamComponent::IO::Decoder::JSON::SSE;
use Ocean::StreamComponent::IO::Encoder::SSE;
use Ocean::StreamComponent::IO::Socket::AEHandleAdapter;
use Ocean::Constants::ProtocolPhase;

sub create_stream {
    my ($self, $client_id, $client_socket) = @_;
    return Ocean::Stream->new(
        id => $client_id,
        io => Ocean::StreamComponent::IO->new(
            decoder  => Ocean::StreamComponent::IO::Decoder::JSON->new(
                protocol => Ocean::StreamComponent::IO::Decoder::JSON::SSE->new, 
            ), 
            encoder  => Ocean::StreamComponent::IO::Encoder::SSE->new,
            socket   => $client_socket,
        ),
        initial_protocol => Ocean::Constants::ProtocolPhase::HTTP_SESSION_HANDSHAKE,
    );
}

1;
