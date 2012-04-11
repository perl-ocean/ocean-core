package Ocean::Jingle::TURN::AttributeCodec::ChannelNumber;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::TURN::Attribute::ChannelNumber;

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;

    my $number = unpack('n', substr($bytes, 0, 2, ''));
    my $rffu = substr($bytes, 0, 2, '');

    my $attr = Ocean::Jingle::TURN::Attribute::ChannelNumber->new;
    $attr->set(number => $number);

    return $attr;
}

sub encode {
    my ($self, $ctx, $attr) = @_;
    return pack('nxx', $attr->number);
}

1;
