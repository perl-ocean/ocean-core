package Ocean::Constants::SASLErrorType;

use strict;
use warnings;

use constant INCORRECT_ENCODING     => q{incorrect-encoding};
use constant INVALID_AUTHZID        => q{invalid-authzid};
use constant INVALID_MECHANISM      => q{invalid-mechanism};
use constant MECHANISM_TOO_WEAK     => q{mechanism-too-weak};
use constant NOT_AUTHORIZED         => q{not-authorized};
use constant TEMPORARY_AUTH_FAILURE => q{temporary-auth-failure};

1;
