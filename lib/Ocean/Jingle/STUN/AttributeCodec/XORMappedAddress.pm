package Ocean::Jingle::STUN::AttributeCodec::XORMappedAddress;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::XORAddress';
use Ocean::Jingle::STUN::Attribute::XORMappedAddress;

sub create_attribute {
    my $self = shift;
    return Ocean::Jingle::STUN::Attribute::XORMappedAddress->new;
}

1;
