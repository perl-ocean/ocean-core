package Ocean::Jingle::TURN::AttributeCodec::Lifetime;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::TURN::Attribute::Lifetime;

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;

    my $lifetime = unpack('N', substr($bytes, 0, 4, ''));

    my $attr = Ocean::Jingle::TURN::Attribute::Lifetime->new;
    $attr->set(lifetime => $lifetime);

    return $attr;
}

sub encode {
    my ($self, $ctx, $attr) = @_;
    return pack('N', $attr->lifetime);
}

1;
