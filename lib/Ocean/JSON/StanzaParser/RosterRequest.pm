package Ocean::JSON::StanzaParser::RosterRequest;

use strict;
use warnings;

use parent 'Ocean::JSON::StanzaParser';
use Ocean::Stanza::Incoming::RosterRequest;

sub parse {
    my ($self, $obj) = @_;

    return unless exists $obj->{roster};

    my $roster_id  = $obj->{roster}{id};
    my $req = Ocean::Stanza::Incoming::RosterRequest->new($roster_id, 1);

    return $req;
}

1;
