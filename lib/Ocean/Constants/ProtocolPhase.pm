package Ocean::Constants::ProtocolPhase;

use strict;
use warnings;

use constant HTTP_HANDSHAKE          => 0;
use constant HTTP_SESSION_HANDSHAKE  => 1;
use constant TLS_STREAM              => 2;
use constant TLS                     => 3;
use constant SASL_STREAM             => 4;
use constant SASL                    => 5;
use constant BIND_AND_SESSION_STREAM => 6;
use constant BIND_AND_SESSION        => 7;
use constant ACTIVE                  => 8;
use constant AVAILABLE               => 9;

1;


