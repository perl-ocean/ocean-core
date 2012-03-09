package Ocean::Stanza::Incoming::Presence;

use strict;
use warnings;

use Ocean::Constants::PresenceShow;

use constant {
    SHOW   => 0,
    STATUS => 1,
};

sub new {
    my ($class, $show, $status) = @_;
    my $self = bless [], $class;
    $self->[ SHOW   ] = $show   || Ocean::Constants::PresenceShow::CHAT;
    $self->[ STATUS ] = $status || '';
    return $self;
}

sub show     { $_[0]->[SHOW]   }
sub status   { $_[0]->[STATUS] }
sub priority { 0 }

1;
