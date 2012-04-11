package Ocean::Jingle::STUN::Authenticator::ShortTermCredential;

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
    gen_short_term_key
);

sub get_password {
    my ($self, $ctx, $username) = @_;
}

sub verify_message_integrity {
    my ($self, $ctx, $msg) = @_;

    if (!$msg->got_message_integrity) {
        debugf('<MessageVerifier> message-integrity not found');
        # 400
        return 0;
    }

    my $i_attr = $msg->get_attribute(MESSAGE_INTEGRITY);
    my $u_attr = $msg->get_attribute(USERNAME);

    # 400
    return unless ($i_attr && $u_attr);

    my $username = $u_attr->username;

    my $password = $self->get_password($ctx, $username);
    unless ($password) {
        # 401
        return;
    }

    my $key = gen_short_term_key($password);
    # 401
    return 0 unless $key;

    my $target = $i_attr->target;

    if ($msg->got_fingerprint) {
        my $length_bytes = pack('n', $msg->length - 8);
        substr($target, 2, 2, $length_bytes);
    }

    unless($i_attr->hash eq calc_message_integrity($target, $key)) {
        # 401
        return 0;
    }

    return 1;
}

1;
