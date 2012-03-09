package Ocean::StreamFactory::Default;

use strict;
use warnings;

use parent 'Ocean::StreamFactory';

use Ocean::Stream;
use Ocean::StreamComponent::IO;
use Ocean::StreamComponent::IO::Decoder::Default;
use Ocean::StreamComponent::IO::Encoder::Default;

sub create_stream {
    my ($self, $client_id, $client_socket) = @_;
    return Ocean::Stream->new(
        id => $client_id,
        io => Ocean::StreamComponent::IO->new(
            decoder => Ocean::StreamComponent::IO::Decoder::Default->new, 
            encoder => Ocean::StreamComponent::IO::Encoder::Default->new,
            socket  => $client_socket,
        ),
    );
}

1;
