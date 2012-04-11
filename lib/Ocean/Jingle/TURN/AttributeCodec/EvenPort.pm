package Ocean::Jingle::TURN::AttributeCodec::EvenPort;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::TURN::Attribute::EvenPort;

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;
    my $attr = Ocean::Jingle::TURN::Attribute::EvenPort->new;
    my $R = ( vec($bytes, 0, 8) & 0b10000000 == 0b10000000 ) ? 1 : 0;
    $attr->set(R => $R);
    return $attr;
}

sub encode {
    my ($self, $ctx, $attr) = @_;
    my $bytes = $attr->R ? pack('C', 0b10000000) : "\0";
    return $bytes;
}

1;
