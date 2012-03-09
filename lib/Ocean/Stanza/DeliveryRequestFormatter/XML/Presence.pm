package Ocean::Stanza::DeliveryRequestFormatter::XML::Presence;

use strict;
use warnings;

use Ocean::Util::XML qw(escape_xml_char);
use Ocean::XML::Namespaces qw(MUC_USER);

sub format {
    my ($class, $presence) = @_;
    my $xml = '<presence from="' . $presence->from . '"';
    if ($presence->to) {
        $xml .= ' to="' . $presence->to . '">';
    } else {
        $xml .= '>';
    }
    $xml .= '<status>' . escape_xml_char($presence->status) . '</status>' if $presence->status;
    $xml .= '<show>' . escape_xml_char($presence->show) . '</show>' if $presence->show;
    $xml .= '<priority>' . $presence->priority . '</priority>';
    if ($presence->is_for_room) {
        $xml .= sprintf '<x xmlns="%s">', MUC_USER;
        $xml .= '<item affiliation="member" role="participant"';
        $xml .= sprintf ' jid="%s"', $presence->raw_jid->as_string if $presence->raw_jid;
        $xml .= '/>';
        if ($presence->room_statuses) {
            for my $status ( @{ $presence->room_statuses } )  {
                $xml .= sprintf '<status code="%s"/>', $status; 
            }
        }
        $xml .= '</x>';
    }
    #$xml .= $presence->[CAPS]->as_xml() if $presence->[CAPS];
    if ($presence->image_hash) {
        $xml .= '<x xmlns="vcard-temp:x:update"><photo>';
        $xml .= $presence->image_hash;
        $xml .= '</photo></x>';
    }
    $xml .= '</presence>';
    return $xml;
}

1;
