package Ocean::Stanza::DeliveryRequestFormatter::XML::RoomInvitation;

use strict;
use warnings;

use Ocean::Util::XML qw(escape_xml_char);
use Ocean::XML::Namespaces qw(MUC_USER);

sub format {
    my ($class, $invitation) = @_;
    my $xml = sprintf('<message from="%s" to="%s">', 
        $invitation->from,
        $invitation->to);
    $xml .= sprintf '<x xmlns="%s">', 
        MUC_USER;
    $xml .= sprintf '<invite from="%s">', 
        $invitation->invitor;
    $xml .= sprintf '<reason>%s</reason>',
        escape_xml_char($invitation->reason) if $invitation->reason;
    $xml .= sprintf '<continue thread="%s"/>', 
        escape_xml_char($invitation->thread) if $invitation->thread;
    $xml .= '</invite>';
    $xml .= '</x>';
    $xml .= '</message>';

    return $xml;
}

1;
