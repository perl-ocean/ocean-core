package Ocean::Jingle::TURN::AttributeCodec::RequestedTransport;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::TURN::Attribute::RequestedTransport;

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;

    my $attr = Ocean::Jingle::TURN::Attribute::RequestedTransport->new;
    return $attr;
}

sub encode {
    my ($self, $ctx, $attr) = @_;
    return '';
}

1;
