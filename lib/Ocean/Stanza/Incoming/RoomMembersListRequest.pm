package Ocean::Stanza::Incoming::RoomMembersListRequest;

use strict;
use warnings;

use constant {
    ID   => 0,
    ROOM => 1,
};

sub new {
    my ($class, $id, $room) = @_;
    my $self = bless [$id, $room], $class;
    return $self;
}

sub id   { $_[0]->[ID]   }
sub room { $_[0]->[ROOM] }

1;
