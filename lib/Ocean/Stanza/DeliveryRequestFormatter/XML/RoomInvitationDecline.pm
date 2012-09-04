package Ocean::Stanza::DeliveryRequestFormatter::XML::RoomInvitationDecline;

use strict;
use warnings;

use Ocean::Util::XML qw(escape_xml_char);
use Ocean::XML::Namespaces qw(MUC_USER);

sub format {
    my ($class, $decline) = @_;
    my $xml = sprintf('<message from="%s" to="%s">', 
        $decline->from,
        $decline->to);
    $xml .= sprintf '<x xmlns="%s">', 
        MUC_USER;
    $xml .= sprintf '<decline from="%s">', 
        $decline->decliner;
    $xml .= sprintf '<reason>%s</reason>',
        escape_xml_char($decline->reason) if $decline->reason;
    $xml .= sprintf '<continue thread="%s"/>', 
        escape_xml_char($decline->thread) if $decline->thread;
    $xml .= '</decline>';
    $xml .= '</x>';
    $xml .= '</message>';

    return $xml;
}

1;
