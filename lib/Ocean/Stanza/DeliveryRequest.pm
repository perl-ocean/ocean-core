package Ocean::Stanza::DeliveryRequest;

use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _type  => $args{type},
        _args  => $args{args},
    }, $class;
    return $self;
}

sub type { $_[0]->{_type} }
sub args { $_[0]->{_args} }

sub as_hash  {
    my $self = shift;
    return {
        type => $self->{_type},
        args => $self->{_args},
    };
}

1;
