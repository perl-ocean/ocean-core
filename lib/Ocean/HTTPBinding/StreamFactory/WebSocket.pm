package Ocean::HTTPBinding::StreamFactory::WebSocket;

use strict;
use warnings;

use parent 'Ocean::StreamFactory';

use AnyEvent::Handle;

use Ocean::Stream;
use Ocean::StreamComponent::IO;
use Ocean::StreamComponent::IO::Decoder::JSON;
use Ocean::StreamComponent::IO::Decoder::JSON::WebSocket::Draft10;
use Ocean::StreamComponent::IO::Encoder::WebSocket::Draft10;
use Ocean::StreamComponent::IO::Socket::AEHandleAdapter;
use Ocean::Constants::ProtocolPhase;

sub create_stream {
    my ($self, $client_id, $client_socket) = @_;
    return Ocean::Stream->new(
        id => $client_id,
        io => Ocean::StreamComponent::IO->new(
            decoder  => Ocean::StreamComponent::IO::Decoder::JSON->new(
                protocol => Ocean::StreamComponent::IO::Decoder::JSON::WebSocket::Draft10->new, 
            ), 
            encoder  => Ocean::StreamComponent::IO::Encoder::WebSocket::Draft10->new,
            socket   => $client_socket,
        ),
        initial_protocol => Ocean::Constants::ProtocolPhase::HTTP_SESSION_HANDSHAKE,
    );
}

1;
