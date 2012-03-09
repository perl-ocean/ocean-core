package Ocean::ProjectTemplate::Context;

use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _params => {}, 
    }, $class;
    return $self;
}

sub set {
    my ($self, $key, $value) = @_;
    $self->{_params}{$key} = $value;
}

sub get {
    my ($self, $key) = @_;
    return $self->{_params}{$key} || '';
}

1;
