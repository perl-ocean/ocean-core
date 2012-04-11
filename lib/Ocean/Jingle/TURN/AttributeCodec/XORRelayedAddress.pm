package Ocean::Jingle::TURN::AttributeCodec::XORRelayedAddress;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::XORAddress';
use Ocean::Jingle::TURN::Attribute::XORRelayedAddress;

sub create_attribute {
    my $self = shift;
    return Ocean::Jingle::TURN::Attribute::XORRelayedAddress->new;
}

1;
