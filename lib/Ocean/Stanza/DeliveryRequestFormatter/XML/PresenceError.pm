package Ocean::Stanza::DeliveryRequestFormatter::XML::PresenceError;

use strict;
use warnings;

use Ocean::Util::XML qw(escape_xml_char);
use Ocean::XML::Namespaces qw(CHAT_STATES STANZAS MUC);
use Ocean::Constants::StanzaErrorType;
use Ocean::Constants::StanzaErrorCondition;

sub format {
    my ($class, $presence) = @_;
    my $xml = '<presence type="error" from="' . $presence->from . '"';
    if ($presence->to) {
        $xml .= ' to="' . $presence->to . '">';
    } else {
        $xml .= '>';
    }
    $xml .= '<status>' . escape_xml_char($presence->status) . '</status>' if $presence->status;
    $xml .= '<show>' . escape_xml_char($presence->show) . '</show>' if ($presence->show);
    $xml .= '<priority>' . $presence->priority . '</priority>';
    $xml .= sprintf '<x xmlns="%s"/>', MUC if $presence->is_for_room;
    #$xml .= $presence->[CAPS]->as_xml() if $presence->[CAPS];
    if ($presence->image_hash) {
        $xml .= '<x xmlns="vcard-temp:x:update"><photo>';
        $xml .= $presence->image_hash;
        $xml .= '</photo></x>';
    }
    $xml .= sprintf '<error type="%s">', $presence->error_type;
    $xml .= sprintf '<%s xmlns="%s"/>', $presence->error_reason, STANZAS;
    if ($presence->error_text) {
        $xml .= sprintf '<text xmlns="%s">', STANZAS;
        $xml .= escape_xml_char($presence->error_text);
        $xml .= '</text>';
    }
    $xml .= '</error>';
    $xml .= '</presence>';
    return $xml;
}

1;
