package Ocean::Jingle::TURN::AttributeCodec::Data;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::TURN::Attribute::Data;

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;
    my $attr = Ocean::Jingle::TURN::AttributeCodec::Data->new;
    $attr->set(data => $bytes);
    return $attr;
}

sub encode {
    my ($self, $ctx, $attr) = @_;
    return $attr->data;
}

1;
