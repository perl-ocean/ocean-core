package Ocean::Constants::StreamErrorType;

use strict;
use warnings;

use constant BAD_FORMAT               => q{bad-format};
use constant BAD_NAMESPACE_PREFIX     => q{bad-namespace-prefix};
use constant CONFLICT                 => q{conflict};
use constant CONNECTION_TIMEOUT       => q{connection-timeout};
use constant HOST_GONE                => q{host-gone};
use constant HOST_UNKNOWN             => q{host-unknown};
use constant IMPROPER_ADDRESSING      => q{improper-addressing};
use constant INTERNAL_SERVER_ERROR    => q{internal-server-error};
use constant INVALID_FORM             => q{invalid-form};
use constant INVALID_ID               => q{invalid-id};
use constant INVALID_NAMESPACE        => q{invalid-namespace};
use constant INVALID_XML              => q{invalid-xml};
use constant NOT_AUTHORIZED           => q{not-authorized};
use constant POLICY_VIOLATION         => q{policy-violation};
use constant REMOTE_CONNECTION_FAILED => q{remote-connection-failed};
use constant REOSURCE_CONSTRAINT      => q{resource-constraint};
use constant RESTRICTED_XML           => q{restricted-xml};
use constant SEE_OTHER_HOST           => q{see-other-host};
use constant SYSTEM_SHUTDOWN          => q{system-shutdown};
use constant UNDEFINED_CONDITION      => q{undefined-condition};
use constant UNSUPPORTED_ENCODING     => q{unsupported-encoding};
use constant UNSUPPORTED_STANZA_TYPE  => q{unsupported-stanza-type};
use constant UNSUPPORTED_VERSION      => q{unsupported-version};
use constant XML_NOT_WELL_FORMED      => q{xml-not-well-formed};

use constant INVALID_JSON             => q{json-xml};
use constant RESTRICTED_JSON          => q{restricted-json};
use constant JSON_NOT_WELL_FORMED     => q{json-not-well-formed};
1;
