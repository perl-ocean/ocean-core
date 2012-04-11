package Ocean::Jingle::STUN::Authenticator::LongTermCredential;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Authenticator';
use Ocean::Jingle::STUN::AttributeType qw(
    MESSAGE_INTEGRITY 
    USERNAME 
    REALM 
    NONCE 
);
use Ocean::Jingle::STUN::Util qw(
    calc_message_integrity 
    gen_long_term_key
);

sub get_password {
    my ($self, $ctx, $username, $nonce) = @_;
    # template method
    # 438 stale nonce
    # 401 invalid user
    return '';
}

sub verify_message_integrity {
    my ($self, $ctx, $msg) = @_;

    if (!$msg->got_message_integrity) {
        debugf('<MessageVerifier> message-integrity not found');
        # 401
        return 0;
    }

    my $i_attr = $msg->get_attribute(MESSAGE_INTEGRITY);
    my $u_attr = $msg->get_attribute(USERNAME);
    my $r_attr = $msg->get_attribute(REALM);
    my $n_attr = $msg->get_attribute(NONCE);

    # 400
    return 0 unless $u_attr && $r_attr && $n_attr;

    my $username = $u_attr->username;
    my $nonce    = $n_attr->nonce;
    my $realm    = $r_attr->realm;

    return 0 unless $self->{_realm} eq $realm;

    my $password = $self->get_password($ctx, $username, $realm, $nonce);

    my $key = gen_long_term_key($username, $realm, $password);
    return 0 unless $key;

    my $target = $i_attr->target;

    if ($msg->got_fingerprint) {
        my $length_bytes = pack('n', $msg->length - 8);
        substr($target, 2, 2, $length_bytes);
    }

    unless($i_attr->hash eq calc_message_integrity($target, $key)) {
        return 0;
    }

    return 1;
}

1;
