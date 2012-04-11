package Ocean::Jingle::STUN::AttributeCodec::Nonce;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::STUN::Attribute::Nonce;

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;

    my $text = substr $bytes, 0, $length, '';

    my $attr = Ocean::Jingle::STUN::Attribute::Nonce->new;
    $attr->set(nonce => $text);

    return $attr;
}

sub encode {
    my ($self, $ctx, $attr) = @_;
    return $attr->nonce;
}

1;
