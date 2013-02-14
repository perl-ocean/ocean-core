package Ocean::ServerComponentFactory::WebSocket;

use strict;
use warnings;

use parent 'Ocean::ServerComponentFactory';

use Ocean::StreamFactory::WebSocket;
use Ocean::StreamManager::Default;

sub create_stream_manager {
    my ($self, $config) = @_;
    return Ocean::StreamManager::Default->new;
}

sub create_stream_factory {
    my ($self, $config) = @_;
    return Ocean::StreamFactory::WebSocket->new;
}

1;
