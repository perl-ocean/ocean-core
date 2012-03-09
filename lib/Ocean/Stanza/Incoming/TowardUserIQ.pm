package Ocean::Stanza::Incoming::TowardUserIQ;

use strict;
use warnings;

use constant {
    ID   => 0,
    TYPE => 1,
    TO   => 2,
    RAW  => 3,
};

sub new {
    my ($class, $id, $type, $to, $raw) = @_;
    my $self = bless [$id, $type, $to, $raw], $class;
    return $self;
}

sub id   { $_[0]->[ID]   }
sub type { $_[0]->[TYPE] }
sub to   { $_[0]->[TO]   }
sub raw  { $_[0]->[RAW]  }

1;
