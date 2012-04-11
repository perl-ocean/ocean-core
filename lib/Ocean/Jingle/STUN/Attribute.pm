package Ocean::Jingle::STUN::Attribute;

use strict;
use warnings;

use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _stash => {},
    }, $class;
}

sub type { 
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Jingle::STUN::Attribute::type not implemented}, 
    );
}

sub get {
    my ($self, $key) = @_;
    return $self->{_stash}{$key};
}

sub set {
    my ($self, $key, $value) = @_;
    $self->{_stash}{$key} = $value;;
}

1;
