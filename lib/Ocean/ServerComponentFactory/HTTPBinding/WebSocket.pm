package Ocean::ServerComponentFactory::HTTPBinding::WebSocket;

use strict;
use warnings;

use parent 'Ocean::ServerComponentFactory';

use Ocean::HTTPBinding::StreamFactory::WebSocket;
use Ocean::HTTPBinding::StreamManager;

sub create_stream_manager {
    my ($self, $config) = @_;
    return Ocean::HTTPBinding::StreamManager->new;
}

sub create_stream_factory {
    my ($self, $config) = @_;
    return Ocean::HTTPBinding::StreamFactory::WebSocket->new;
}

1;
