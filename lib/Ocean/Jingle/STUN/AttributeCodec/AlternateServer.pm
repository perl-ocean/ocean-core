package Ocean::Jingle::STUN::AttributeCodec::AlternateServer;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Address';
use Ocean::Jingle::STUN::Attribute::AlternateServer;

sub create_attribute {
    my $self = shift;
    return Ocean::Jingle::STUN::Attribute::AlternateServer->new;
}

1;
