package Ocean::Jingle::STUN::AttributeCodec::Username;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::STUN::Attribute::Username;

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;

    my $text = substr $bytes, 0, $length, '';

    my $attr = Ocean::Jingle::STUN::Attribute::Username->new;
    $attr->set(username => $text);

    return $attr;
}

sub encode {
    my ($self, $ctx, $attr) = @_;
    return $attr->username;
}

1;
