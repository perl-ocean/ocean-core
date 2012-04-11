package Ocean::Jingle::STUN::AttributeCodec::MessageIntegrity;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::STUN::Attribute::MessageIntegrity;

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;

    my $attr = 
        Ocean::Jingle::STUN::Attribute::MessageIntegrity->new;
    my $hash = substr $bytes, 0, 20, '';
    $attr->set(hash => $hash);

    # copy bytes already read
    $attr->set(target => $ctx->read_bytes);

    return $attr;
}

1;
