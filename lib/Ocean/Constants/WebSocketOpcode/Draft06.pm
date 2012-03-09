package Ocean::Constants::WebSocketOpcode::Draft06;

use strict;
use warnings;

use constant {
    CONTINUATION => 0,
    CLOSE        => 1,
    PING         => 2,
    PONG         => 3,
    TEXT_FRAME   => 4,
    BINARY_FRAME => 5,
};

1;

