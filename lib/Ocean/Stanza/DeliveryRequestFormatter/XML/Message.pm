package Ocean::Stanza::DeliveryRequestFormatter::XML::Message;

use strict;
use warnings;

use Ocean::Util::XML qw(escape_xml_char);
use Ocean::XML::Namespaces qw(CHAT_STATES XHTML_IM XHTML);

sub format {
    my ($class, $message) = @_;
    my $xml = sprintf('<message type="%s"', 
        $message->type);
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
    if (defined $message->body) {
        $xml .= sprintf(q{<body>%s</body>},
            escape_xml_char($message->body));
    }
    if ($message->html) {
        $xml .= sprintf(q{<html xmlns="%s">}, XHTML_IM);
        $xml .= sprintf(q{<body xmlns="%s">}, XHTML);
        $xml .= $message->html;
        $xml .= '</body>';
        $xml .= '</html>';
    }
    $xml .= '</message>';
    return $xml;
}

1;
