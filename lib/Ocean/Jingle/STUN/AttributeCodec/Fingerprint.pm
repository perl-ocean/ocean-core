package Ocean::Jingle::STUN::AttributeCodec::Fingerprint;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec';
use Ocean::Jingle::STUN::Attribute::Fingerprint;

sub check_order {
    my ($self, $ctx) = @_;
    return ($ctx->got_fingerprint) ? 0 : 1;
}

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;

    my $attr = 
        Ocean::Jingle::STUN::Attribute::Fingerprint->new;

    my $masked_crc = substr $bytes, 0, 4, '';
    my $crc = vec($masked_crc, 0, 32) ^ 0x5354554e;
    $attr->set(crc => $crc);

    # copy bytes already read
    $attr->set(target => $ctx->read_bytes);

    return $attr;
}

1;
