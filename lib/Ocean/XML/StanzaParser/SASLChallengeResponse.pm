package Ocean::XML::StanzaParser::SASLChallengeResponse;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaParser';

use Ocean::Util::XML qw(unescape_xml_char);
use Ocean::Error;
use Ocean::Stanza::Incoming::SASLChallengeResponse;

sub parse {
    my ($class, $element) = @_;

    # TODO Base64 decode here?
    my $text = $element->text
        ? unescape_xml_char($element->text) : '';

    return Ocean::Stanza::Incoming::SASLChallengeResponse->new($text);
}

1;
