package Ocean::Stanza::Incoming::TowardRoomMemberIQ;

use strict;
use warnings;

use constant {
    ID       => 0,
    TYPE     => 1,
    ROOM     => 2,
    NICKNAME => 3,
    RAW      => 4,
};

sub new {
    my ($class, $id, $type, $room, $nickname, $raw) = @_;
    my $self = bless [$id, $type, $room, $nickname, $raw], $class;
    return $self;
}

sub id       { $_[0]->[ID]       }
sub type     { $_[0]->[TYPE]     }
sub room     { $_[0]->[ROOM]     }
sub nickname { $_[0]->[NICKNAME] }
sub raw      { $_[0]->[RAW]      }

1;
