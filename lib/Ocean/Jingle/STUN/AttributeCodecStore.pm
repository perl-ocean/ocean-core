package Ocean::Jingle::STUN::AttributeCodecStore;

use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = bless {
        _store => {}, 
    }, $class;
    return $self;
}

sub register_codec {
    my ($self, $attr_type, $reader) = @_;
    $self->{_store}{$attr_type} = $reader;
}

sub get_codec {
    my ($self, $attr_type) = @_;
    return $self->{_store}{$attr_type};
}

1;
