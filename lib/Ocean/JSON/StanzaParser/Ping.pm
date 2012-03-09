package Ocean::JSON::StanzaParser::Ping;

use strict;
use warnings;

use parent 'Ocean::JSON::StanzaParser';
use Ocean::Stanza::Incoming::Ping;

sub parse {
    my ($self, $obj) = @_;

    return unless exists $obj->{ping};

    my $ping_id  = $obj->{ping}{id};
    my $ping = Ocean::Stanza::Incoming::Ping->new($ping_id);

    return $ping;
}

1;
