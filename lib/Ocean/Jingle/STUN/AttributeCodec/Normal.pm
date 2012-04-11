package Ocean::Jingle::STUN::AttributeCodec::Normal;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec';

sub check_order {
    my ($self, $ctx) = @_;
    return ($ctx->got_message_integrity || $ctx->got_fingerprint) ? 0 : 1;
}

1;
