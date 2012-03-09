package Ocean::Stanza::Incoming::SASLChallengeResponse;

use strict;
use warnings;

use constant {
    TEXT  => 0,
};

sub new {
    my ($class, $text) = @_;
    my $self = bless [$text], $class;
    return $self;
}

sub text { $_[0]->[TEXT] }

1;
