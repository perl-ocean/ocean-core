package Ocean::JSON::StanzaParser::vCardRequest;

use strict;
use warnings;

use parent 'Ocean::JSON::StanzaParser';
use Ocean::Stanza::Incoming::vCardRequest;
use Ocean::JID;

sub parse {
    my ($self, $obj) = @_;

    return unless exists $obj->{vcard};

    my $vcard_id  = $obj->{vcard}{id};
    my $vcard_to  = $obj->{vcard}{to};
    my $vcard_to_jid = Ocean::JID->new($vcard_to);
    my $req = Ocean::Stanza::Incoming::vCardRequest->new($vcard_id, $vcard_to_jid, 1);

    return $req;
}

1;
