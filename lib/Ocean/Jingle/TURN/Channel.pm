package Ocean::Jingle::TURN::Channel;

use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
    }, $class;
    return $self;
}

1;
