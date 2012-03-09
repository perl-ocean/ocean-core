package Ocean::Stanza::Incoming::RoomInvitationDecline;

use strict;
use warnings;

use constant {
    ROOM   => 0,
    TO     => 1,
    REASON => 2,
    THREAD => 3,
};

sub new {
    my ($class, $room, $to, $reason, $thread) = @_;
    my $self = bless [$room, $to, $reason, $thread], $class;
    return $self;
}

sub room   { $_[0]->[ROOM]   }
sub to     { $_[0]->[TO]     }
sub reason { $_[0]->[REASON] }
sub thread { $_[0]->[THREAD] }

1;
