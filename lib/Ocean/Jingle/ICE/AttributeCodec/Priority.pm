package Ocean::Jingle::ICE::AttributeCodec::Priority;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::ICE::Attribute::Priority;

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;

    my $priority = unpack('N', substr($bytes, 0, 4, ''));

    my $attr = Ocean::Jingle::ICE::Attribute::Priority->new;
    $attr->set(priority => $priority);

    return $attr;
}

sub encode {
    my ($self, $ctx, $attr) = @_;
    return pack('N', $attr->priority);
}

1;
