package Ocean::Jingle::STUN::MessageVerifier::LongTermCredential;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::MessageVerifier';

use Ocean::Jingle::STUN::AttributeType qw(USERNAME REALM NONCE);
use Ocean::Jingle::STUN::Util qw(gen_long_term_key);

sub gen_key {
    my ($self, $msg) = @_;

    my $u_attr = $msg->get_attribute(USERNAME);
    my $r_attr = $msg->get_attribute(REALM);
    my $n_attr = $msg->get_attribute(NONCE);

    return 0 unless $u_attr && $r_attr && $n_attr;

    # my $password = $self->get_password($username, $nonce);

    return gen_long_term_key($u_attr->username, $r_attr->realm, $self->{_password});
}

1;
