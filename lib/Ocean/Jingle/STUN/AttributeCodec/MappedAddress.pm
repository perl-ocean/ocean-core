package Ocean::Jingle::STUN::AttributeCodec::MappedAddress;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Address';
use Ocean::Jingle::STUN::Attribute::MappedAddress;

sub create_attribute {
    my $self = shift;
    return Ocean::Jingle::STUN::Attribute::MappedAddress->new;
}

1;
