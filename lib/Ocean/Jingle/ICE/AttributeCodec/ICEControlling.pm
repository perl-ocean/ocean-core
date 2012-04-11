package Ocean::Jingle::ICE::AttributeCodec::ICEControlling;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::ICE::Attribute::ICEControlling;

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;

    # 64bit unsigned integer
    my $value = unpack('H16', substr($bytes, 0, 8, ''));

    my $attr = Ocean::Jingle::ICE::Attribute::ICEControlling->new;
    $attr->set(value => $value);

    return $attr;
}

sub encode {
    my ($self, $ctx, $attr) = @_;
    return pack('H16', $attr->value);
}

1;
