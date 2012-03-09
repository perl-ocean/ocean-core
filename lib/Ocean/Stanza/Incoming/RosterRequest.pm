package Ocean::Stanza::Incoming::RosterRequest;

use strict;
use warnings;

use constant {
    ID             => 0,
    WANT_PHOTO_URL => 1,
};

sub new {
    my ($class, $id, $want_photo_url) = @_;
    my $self = bless [$id, $want_photo_url ], $class;
    return $self;
}

sub id { $_[0]->[ID] }
sub want_photo_url { $_[0]->[WANT_PHOTO_URL] }

1;
