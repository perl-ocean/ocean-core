package Ocean::Stanza::DeliveryRequestFormatter::XML::MessageError;

use strict;
use warnings;

use Ocean::Util::XML qw(escape_xml_char);
use Ocean::XML::Namespaces qw(CHAT_STATES STANZAS);
use Ocean::Constants::StanzaErrorType;
use Ocean::Constants::StanzaErrorCondition;

sub format {
    my ($class, $message) = @_;

    my $error_type   = $message->error_type   || Ocean::Constants::StanzaErrorType::CANCEL;
    my $error_reason = $message->error_reason || Ocean::Constants::StanzaErrorCondition::BAD_REQUEST;

    my $xml = '<message type="error"';
    if ($message->from) {
        $xml .= sprintf(q{ from="%s"}, 
            $message->from);
    }
    if ($message->to) {
        $xml .= sprintf(q{ to="%s"}, 
            $message->to);
    }
    $xml .= '>';
    if ($message->subject) {
        $xml .= sprintf(q{<subject>%s</subject>},
            escape_xml_char($message->subject));
    }
    if ($message->thread) {
        $xml .= sprintf(q{<thread>%s</thread>},
            escape_xml_char($message->thread));
    }
    if ($message->state) {
        $xml .= sprintf(q{<%s xmlns="%s"/>},
            $message->state, CHAT_STATES);
    }
    if ($message->body) {
        $xml .= sprintf(q{<body>%s</body>},
            escape_xml_char($message->body));
    }
    $xml .= sprintf '<error type="%s">', $error_type;
    $xml .= sprintf '<%s xmlns="%s"/>', $error_reason, STANZAS;
    if ($message->error_text) {
        $xml .= sprintf '<text xmlns="%s">', STANZAS;
        $xml .= escape_xml_char($message->error_text);
        $xml .= '</text>';
    }
    $xml .= '</error>';
    $xml .= '</message>';
    return $xml;
}

1;
