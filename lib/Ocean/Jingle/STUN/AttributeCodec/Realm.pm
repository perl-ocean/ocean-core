package Ocean::Jingle::STUN::AttributeCodec::Realm;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::STUN::Attribute::Realm;

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;

    my $text = substr $bytes, 0, $length, '';

    my $attr = Ocean::Jingle::STUN::Attribute::Realm->new;
    $attr->set(realm => $text);

    return $attr;
}

sub encode {
    my ($self, $ctx, $attr) = @_;
    return $attr->realm;
}

1;
