package Ocean::JSON::StanzaParser::Session;

use strict;
use warnings;

use parent 'Ocean::JSON::StanzaParser';
use Ocean::Stanza::Incoming::Session;

sub parse {
    my ($self, $obj) = @_;

    return unless exists $obj->{session};

    my $session_id  = $obj->{session}{id};
    my $req = Ocean::Stanza::Incoming::Session->new($session_id);
    return $req;
}

1;
