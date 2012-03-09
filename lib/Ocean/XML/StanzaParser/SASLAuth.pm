package Ocean::XML::StanzaParser::SASLAuth;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaParser';

use Ocean::Util::XML qw(unescape_xml_char);
use Ocean::Error;
use Ocean::Stanza::Incoming::SASLAuth;

sub parse {
    my ($class, $element) = @_;

    my $mech = $element->attr('mechanism');
    unless ($mech) {
        Ocean::Error::ProtocolError->throw(
            message => q{auth@mechanism not found});
    }

    # TODO Base64 decode here?
    my $text = $element->text
        ? unescape_xml_char($element->text) : '';

    return Ocean::Stanza::Incoming::SASLAuth->new($mech, $text);
}

1;
