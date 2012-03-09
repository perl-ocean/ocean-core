package Ocean::Constants::StanzaErrorCondition;

use strict;
use warnings;

use constant BAD_REQUEST             => q{bad-request};
use constant CONFLICT                => q{conflict};
use constant FEATURE_NOT_IMPLEMENTED => q{feature-not-implemented};
use constant FORBIDDEN               => q{forbidden};
use constant GONE                    => q{gone};
use constant INTERNAL_SERVER_ERROR   => q{internal-server-error};
use constant ITEM_NOT_FOUND          => q{item-not-found};
use constant JID_MALFORMED           => q{jid-malformed};
use constant NOT_ACCEPTABLE          => q{not-acceptable};
use constant NOT_ALLOWED             => q{not-allowed};
use constant PAYMENT_REQUIRED        => q{payment-required};
use constant RECIPIENT_UNAVAILABLE   => q{recipient_unavailable};
use constant REDIRECT                => q{redirect};
use constant REGISTRATION_REQUIRED   => q{registration_required};
use constant REMOTE_SERVER_TIMEOUT   => q{remote-server-timeout};
use constant RESOURCE_CONSTRAINT     => q{resource-constraint};
use constant SERVICE_UNAVAILABLE     => q{service-unavailable};
use constant SUBSCRIPTION_REQUIRED   => q{subscription-required};
use constant UNDEFINED_CONDITION     => q{undefined-condition};
use constant UNEXPECTED_REQUEST      => q{unexpected-request};

1;
