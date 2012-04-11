package Ocean::Jingle::STUN::AttributeCodec::UnknownAttributes;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::STUN::Attribute::UnknownAttributes;

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;

    my $attr = Ocean::Jingle::STUN::Attribute::UnknownAttributes->new;

    my $read_length = 0;
    while ($read_length < $length) {
        my $attribute = substr $bytes, 0, 16, '';
        $attr->add_attribute($attribute) 
            unless $attribute ne "\0\0"; # "\0\0" padding
        $read_length += 16;
    }

    return $attr;
}

sub encode {
    my ($self, $ctx, $attr) = @_;
    return join '', @{ $attr->attributes };
}

1;
