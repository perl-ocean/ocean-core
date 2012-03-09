package Ocean::Stanza::Incoming::RoomServiceInfoRequest;

use strict;
use warnings;

use constant {
    ID => 0,
};

sub new {
    my ($class, $id) = @_;
    my $self = bless [$id], $class;
    return $self;
}

sub id { $_[0]->[ID] }

1;
