package Ocean::ServerComponentFactory::HTTPBinding::WebSocket;

use strict;
use warnings;

use parent 'Ocean::ServerComponentFactory';

use Ocean::HTTPBinding::StreamFactory::WebSocket;
use Ocean::HTTPBinding::StreamManager;

sub create_stream_manager {
    my $self = shift;
    my $stream_manager = Ocean::HTTPBinding::StreamManager->new;
    return $stream_manager;
}

sub create_stream_factory {
    my ($self, %args) = @_;
    my $stream_factory = Ocean::HTTPBinding::StreamFactory::WebSocket->new;
    return $stream_factory;
}

1;
