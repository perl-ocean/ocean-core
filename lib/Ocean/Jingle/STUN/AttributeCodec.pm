package Ocean::Jingle::STUN::AttributeCodec;

use strict;
use warnings;

use Ocean::Error;

sub new { bless {}, $_[0] }

sub check_order {
    my ($self, $ctx) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Jingle::STUN::AttributeCodec::check_order not implemented}, 
    );
}

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Jingle::STUN::AttributeCodec::decode not implemented}, 
    );
}

sub encode {
    my ($self, $attr) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Jingle::STUN::AttributeCodec::encode not implemented}, 
    );
}

1;
