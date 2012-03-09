package Ocean::Constants::StreamFeatureType;

use strict;
use warnings;

use constant TLS     => 1;
use constant SASL    => 1 << 1;
use constant BIND    => 1 << 2;
use constant SESSION => 1 << 3;

1;
