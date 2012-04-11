package Ocean::Jingle::STUN::Authenticator;

use strict;
use warnings;

use Ocean::Jingle::STUN::AttributeType qw(
    FINGERPRINT 
    MESSAGE_INTEGRITY 
);
use Ocean::Jingle::STUN::Util qw(calc_fingerprint);
use Ocean::Error;

sub new { 
    my ($class, %args) = @_; 
    my $self = bless {
        _realm               => $args{realm}, 
        _require_fingerprint => $args{require_fingerprint},
    }, $class;
    return $self;
}

sub authenticate {
    my ($self, $ctx, $msg) = @_;
}

sub verify_message_integrity {
    my ($self, $ctx, $msg) = @_;
}

sub verify_fingerprint {
    my ($self, $msg) = @_;

    if ($self->{_require_fingerprint} && !$msg->got_fingerprint) {
        debugf('<Authenticator> fingerprint not found');
        return 0;
    }

    if ($msg->got_fingerprint) {
        my $fingerprint = $msg->get_attribute(FINGERPRINT);
        unless ($fingerprint->crc eq calc_fingerprint($fingerprint->target)) {
            # invalid finger print
            debugf("<Authenticator> fingerprint doesn't match");
            return 0;
        }
    }

    return 1;
}

1;
