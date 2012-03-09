package Ocean::ServerComponentFactory::HTTPBinding::XHR;

use strict;
use warnings;

use parent 'Ocean::ServerComponentFactory';

use Ocean::HTTPBinding::StreamFactory::XHR;
use Ocean::HTTPBinding::StreamManager;

sub create_stream_manager {
    my ($self, $config) = @_;
    return Ocean::HTTPBinding::StreamManager->new(
        close_on_deliver => 1, 
    );
}

sub create_stream_factory {
    my ($self, $config) = @_;
    return Ocean::HTTPBinding::StreamFactory::XHR->new;
}

1;
