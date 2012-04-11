package Ocean::Jingle::STUN::AttributeCodec::ErrorCode;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::STUN::Attribute::ErrorCode;

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;

    my $null   = substr $bytes, 0, 2, '';

    my $class  = unpack('C', substr($bytes, 0, 1, ''));
    $class &= 0x07;

    # number should be 0 - 99
    my $number = unpack('C', substr($bytes, 0, 1, ''));

    my $reason = substr $bytes, 0, $length - 4, '';

    my $code = $class + $number;

    my $attr = Ocean::Jingle::STUN::Attribute::ErrorCode->new;
    $attr->set(code => $code);
    $attr->set(reason => $reason);

    return $attr;
}

sub encode {
    my ($self, $ctx, $attr) = @_;

    my $code   = $attr->code;
    my $reason = $attr->reason;

    my $class  = int($code / 100);
    my $number = $code % 100;

    my $bytes = pack('nnCC', $class, $number);
    $bytes .= $reason;

    return $bytes;
}

1;
