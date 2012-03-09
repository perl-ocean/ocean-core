package Ocean::Constants::WebSocketOpcode;

use strict;
use warnings;

use constant {
    CONTINUATION =>  0,
    TEXT_FRAME   =>  1,
    BINARY_FRAME =>  2,
    CLOSE        =>  8,
    PING         =>  9,
    PONG         => 10,
};

1;

