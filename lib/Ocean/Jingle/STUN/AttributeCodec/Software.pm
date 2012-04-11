package Ocean::Jingle::STUN::AttributeCodec::Software;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::STUN::Attribute::Software;

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;

    my $text = substr $bytes, 0, $length, '';

    my $attr = Ocean::Jingle::STUN::Attribute::Software->new;
    $attr->set(software => $text);

    return $attr;
}

sub encode {
    my ($self, $ctx, $attr) = @_;
    return $attr->software;
}

1;
