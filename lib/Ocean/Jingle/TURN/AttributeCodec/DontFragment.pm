package Ocean::Jingle::TURN::AttributeCodec::DontFragment;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::TURN::Attribute::DontFragment;

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;

    my $attr = Ocean::Jingle::TURN::Attribute::DontFragment->new;
    return $attr;
}

sub encode {
    my ($self, $ctx, $attr) = @_;
    return '';
}

1;
