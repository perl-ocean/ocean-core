package Ocean::Jingle::STUN::ErrorCode;

use strict;
use warnings;

use constant TRY_ALTERNATE                  => 300;
use constant BAD_REQUEST                    => 400;
use constant UNAUTHORIZED                   => 401;
use constant UNKNOWN_ATTRIBUTE              => 420;
use constant STALE_NONCE                    => 438;
use constant SERVER_ERROR                   => 500;
# for TURN
use constant FORBIDDEN                      => 403;
use constant ALLOCATION_MISMATCH            => 437;
use constant WRONG_CREDENTIALS              => 441;
use constant UNSUPPORTED_TRANSPORT_PROTOCOL => 442;
use constant ALLOCATION_QUOTA_REACHED       => 486;
use constant INSUFFICIENT_CAPACITY          => 508;
# for ICE
use constant ROLE_CONFLICT                  => 487;

1;
