package Ocean::Stanza::Incoming::vCardRequest;

use strict;
use warnings;

use constant {
    ID             => 0,
    TO             => 1,
    WANT_PHOTO_URL => 2,
};

sub new {
    my ($class, $id, $to_jid, $want_photo_url) = @_;
    my $self = bless [ $id, $to_jid, $want_photo_url ], $class;
    return $self;
}

sub id { $_[0]->[ID] }
sub to { $_[0]->[TO] = $_[1] if $_[1]; $_[0]->[TO] }
sub want_photo_url { $_[0]->[WANT_PHOTO_URL] }

1;
