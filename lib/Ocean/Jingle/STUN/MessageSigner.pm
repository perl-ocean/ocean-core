package Ocean::Jingle::STUN::MessageSigner;

use strict;
use warnings;

use Digest::SHA;
use Ocean::Jingle::STUN::Util qw(calc_message_integrity);

sub new { bless {}, $_[0] }

sub sign {
    my ($self, $bytes) = @_;
    my $key = $self->get_key();
    return calc_message_integrity($bytes, $key);
}

sub get_key {
    my $self = shift;
    die "abstract method";
}

1;
