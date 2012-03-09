package Ocean::Stanza::Incoming::ChatMessage;

use strict;
use warnings;

use constant {
    TO      => 0,
    BODY    => 1,
    THREAD  => 2,
    STATE   => 3,
    HTML    => 4,
};

sub new {
    my ($class, $to, $body, $thread, $state, $html) = @_;
    my $self = bless [$to, $body, $thread, $state, $html], $class;
    return $self;
}

sub to      { $_[0]->[TO]       }
sub body    { $_[0]->[BODY]     }
sub thread  { $_[0]->[THREAD]   }
sub state   { $_[0]->[STATE]    }
sub html    { $_[0]->[HTML]     }

1;
