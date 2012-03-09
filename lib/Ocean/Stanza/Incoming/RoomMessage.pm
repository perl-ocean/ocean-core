package Ocean::Stanza::Incoming::RoomMessage;

use strict;
use warnings;

use constant {
    ROOM    => 0,
    BODY    => 1,
    SUBJECT => 2,
    HTML    => 3,
};

sub new {
    my ($class, $room, $body, $subject, $html) = @_;
    my $self = bless [$room, $body, $subject, $html], $class;
    return $self;
}

sub room    { $_[0]->[ROOM]    }
sub body    { $_[0]->[BODY]    }
sub subject { $_[0]->[SUBJECT] }
sub html    { $_[0]->[HTML]    }

1;
