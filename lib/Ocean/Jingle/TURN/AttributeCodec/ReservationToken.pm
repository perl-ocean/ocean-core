package Ocean::Jingle::TURN::AttributeCodec::ReservationToken;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::TURN::Attribute::ReservationToken;

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;

    my $token = substr $bytes, 8, '';
    my $attr = Ocean::Jingle::TURN::Attribute::ReservationToken->new;
    $attr->set(token => $token);
    return $attr;
}

1;
