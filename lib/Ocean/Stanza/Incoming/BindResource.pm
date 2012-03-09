package Ocean::Stanza::Incoming::BindResource;

use strict;
use warnings;

use constant  {
    ID          => 0,
    RESOURCE    => 1,
    WANT_EXTVAL => 2,
};

sub new {
    my ($class, $id, $resource, $want_extval) = @_;
    my $self = bless [$id, $resource, $want_extval], $class;
    return $self;
}

sub id          { $_[0]->[ID]          }
sub want_extval { $_[0]->[WANT_EXTVAL] }
sub resource    { $_[0]->[RESOURCE] = $_[1] if $_[1]; $_[0]->[RESOURCE]    }

1;
