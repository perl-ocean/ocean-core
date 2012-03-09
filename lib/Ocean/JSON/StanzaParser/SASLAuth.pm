package Ocean::JSON::StanzaParser::SASLAuth;

use strict;
use warnings;

use parent 'Ocean::JSON::StanzaParser';

use Ocean::Stanza::Incoming::SASLAuth;

sub parse {
    my ($self, $obj) = @_;

    return unless exists $obj->{auth};

    my $auth_mech = $obj->{auth}{mechanism} || '';
    my $auth_text = $obj->{auth}{value}     || '';

    my $auth = Ocean::Stanza::Incoming::SASLAuth->new(
        $auth_mech, $auth_text);

    return $auth;
}

1;
