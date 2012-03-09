package Ocean::Stanza::DeliveryRequestFormatter::XML::IQError;

use strict;
use warnings;

use Ocean::Util::XML qw(escape_xml_char);
use Ocean::XML::Namespaces qw(CHAT_STATES STANZAS);
use Ocean::Constants::StanzaErrorType;
use Ocean::Constants::StanzaErrorCondition;

sub format {
    my ($class, $iq) = @_;

    my $error_type   = $iq->error_type   || Ocean::Constants::StanzaErrorType::CANCEL;
    my $error_reason = $iq->error_reason || Ocean::Constants::StanzaErrorCondition::BAD_REQUEST;

    my $xml = sprintf '<iq id="%s" type="error" from="%s"', $iq->id, $iq->from;
    if ($iq->to) {
        $xml .= ' to="' . $iq->to . '">';
    } else {
        $xml .= '>';
    }
    $xml .= sprintf '<error type="%s">', $error_type;
    $xml .= sprintf '<%s xmlns="%s"/>',  $error_reason, STANZAS;
    if ($iq->error_text) {
        $xml .= sprintf '<text xmlns="%s">', STANZAS;
        $xml .= escape_xml_char($iq->error_text);
        $xml .= '</text>';
    }
    $xml .= '</error>';
    $xml .= '</iq>';
    return $xml;
}

1;
