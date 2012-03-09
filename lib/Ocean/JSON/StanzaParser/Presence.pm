package Ocean::JSON::StanzaParser::Presence;

use strict;
use warnings;

use parent 'Ocean::JSON::StanzaParser';
use Ocean::Stanza::Incoming::Presence;

sub parse {
    my ($self, $obj) = @_;

    return unless exists $obj->{presence};

    my $presence_obj = $obj->{presence};

    my $show   = $presence_obj->{show}   || 'chat';
    my $status = $presence_obj->{status} || '';

    my $presence = 
        Ocean::Stanza::Incoming::Presence->new($show, $status);

    return $presence;
}

1;
