package Ocean::Jingle::STUN::MessageVerifier::ShortTermCredential;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::MessageVerifier';

use Ocean::Jingle::STUN::AttributeType qw(USERNAME);
use Ocean::Jingle::STUN::Util qw(gen_short_term_key);

sub gen_key {
    my ($self, $msg) = @_;
    return gen_short_term_key($self->{_password});
}

1;
