package Ocean::Jingle::STUN::MessageVerifier;

use strict;
use warnings;

use Ocean::Jingle::STUN::AttributeType qw(FINGERPRINT MESSAGE_INTEGRITY);
use Ocean::Jingle::STUN::Util qw(calc_fingerprint calc_message_integrity);

use Log::Minimal;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _password                  => $args{password},
        _require_fingerprint       => $args{require_fingerprint}, 
        _require_message_integrity => $args{require_message_integrity}, 
    }, $class;
    return $self;
}

sub verify {
    my ($self, $msg) = @_;

    return $self->verify_fingerprint($msg)
        && $self->verify_message_integrity($msg); 

}

sub verify_message_integrity {
    my ($self, $msg) = @_;

    if ($self->{_require_message_integrity} && !$msg->got_message_integrity) {
        debugf('<MessageVerifier> message-integrity not found');
        return 0;
    }

    if ($msg->got_message_integrity) {
        my $integrity = $msg->get_attribute(MESSAGE_INTEGRITY);

        my $key = $self->gen_key($msg); 
        return 0 unless $key;

        my $target = $integrity->target;

        if ($msg->got_fingerprint) {
            my $length_bytes = pack('n', $msg->length - 8);
            substr($target, 2, 2, $length_bytes);
        }

        unless($integrity->hash eq calc_message_integrity($target, $key)) {
            return 0;
        }
    }

    return 1;

}

sub gen_key {
    my $self = shift;
    die 'abstract method';
}


sub verify_fingerprint {
    my ($self, $msg) = @_;

    if ($self->{_require_fingerprint} && !$msg->got_fingerprint) {
        debugf('<MessageVerifier> fingerprint not found');
        return 0;
    }

    if ($msg->got_fingerprint) {
        my $fingerprint = $msg->get_attribute(FINGERPRINT);
        unless ($fingerprint->crc eq calc_fingerprint($fingerprint->target)) {
            # invalid finger print
            debugf("<MessageVerifier> fingerprint doesn't match");
            return 0;
        }
    }

    return 1;
}

1;
