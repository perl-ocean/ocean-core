package Ocean::Jingle::TURN::AttributeCodec::XORPeerAddress;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::XORAddress';
use Ocean::Jingle::TURN::Attribute::XORPeerAddress;

sub create_attribute {
    my $self = shift;
    return Ocean::Jingle::TURN::Attribute::XORPeerAddress->new;
}

1;
