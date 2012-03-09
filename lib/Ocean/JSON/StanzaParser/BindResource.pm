package Ocean::JSON::StanzaParser::BindResource;

use strict;
use warnings;

use parent 'Ocean::JSON::StanzaParser';
use Ocean::Stanza::Incoming::BindResource;

sub parse {
    my ($self, $obj) = @_;

    return unless exists $obj->{bind};

    my $bind_id  = $obj->{bind}{id};
    my $resource = $obj->{bind}{resource} || '';

    my $req = Ocean::Stanza::Incoming::BindResource->new(
        $bind_id, $resource, 1);

    return $req;
}

1;
