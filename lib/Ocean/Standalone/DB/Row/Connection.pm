package Ocean::Standalone::DB::Row::Connection;

use strict;
use warnings;

use parent 'Teng::Row';
use Ocean::Stanza::Incoming::Presence;

sub presence {
    my $self = shift;
    return Ocean::Stanza::Incoming::Presence->new(
        $self->presence_show, 
        $self->presence_status,
    );
}

1;
