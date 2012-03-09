package Ocean::Stanza::Incoming::LeaveRoomPresence;

use strict;
use warnings;

use constant {
    ROOM     => 0,
    NICKNAME => 1,
};

sub new {
    my ($class, $room, $nickname) = @_;
    my $self = bless [$room, $nickname], $class;
    return $self;
}

sub room     { $_[0]->[ROOM]     }
sub nickname { $_[0]->[NICKNAME] }

1;
