package Ocean::Stanza::Incoming::RoomPresence;

use strict;
use warnings;

use constant {
    ROOM     => 0,
    NICKNAME => 1,
    SHOW     => 2,
    STATUS   => 3,
};

sub new {
    my ($class, $room, $nickname, $show, $status) = @_;
    my $self = bless [$room, $nickname, $show, $status], $class;
    return $self;
}

sub room     { $_[0]->[ROOM]     }
sub nickname { $_[0]->[NICKNAME] }
sub show     { $_[0]->[SHOW]     }
sub status   { $_[0]->[STATUS]   }

1;
