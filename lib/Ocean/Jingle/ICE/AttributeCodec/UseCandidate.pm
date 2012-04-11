package Ocean::Jingle::ICE::AttributeCodec::UseCandidate;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::ICE::Attribute::UseCandidate;

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;

    my $attr = Ocean::Jingle::ICE::Attribute::UseCandidate->new;

    return $attr;
}

sub encode {
    my ($self, $ctx, $attr) = @_;
    return '';
}

1;
