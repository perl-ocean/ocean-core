package Ocean::Stanza::Incoming::SASLAuth;

use strict;
use warnings;

use constant {
    MECHANISM => 0,
    TEXT      => 1,
};

sub new {
    my ($class, $mech, $text) = @_;
    my $self = bless [$mech, $text], $class;
    return $self;
}

sub mechanism { $_[0]->[MECHANISM] }
sub text      { $_[0]->[TEXT]      }

1;
