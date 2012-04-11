package Ocean::Jingle::STUN::Authenticator::Null;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Authenticator';

sub authenticate {
    my ($self, $msg) = @_;

    return 1;
}

1;
