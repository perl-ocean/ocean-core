package Ocean::Stanza::DeliveryRequestFormatter::XML::RosterItem;

use strict;
use warnings;

use Ocean::Util::XML qw(escape_xml_char);
use Ocean::XML::Namespaces qw(ROSTER_PHOTO);

sub format {
    my ($class, $item) = @_;
    my $xml = '<item';
    $xml .= ' jid="' . $item->jid . '"';
    $xml .= ' subscription="' . $item->subscription . '"';
    if ($item->nickname) {
        $xml .= ' name="' . escape_xml_char($item->nickname) . '"';
    }
    if ($item->is_pending_out) {
        $xml .= ' ask="subscribe"';
    }
    if (@{ $item->groups } > 0 || $item->photo_url) {
        $xml .= '>';
        for my $group ( @{ $item->groups } ) {
            $xml .= '<group>' . escape_xml_char($group) . '</group>';
        }
        if ($item->photo_url) {
            $xml .= '<photo_url xmlns="' . ROSTER_PHOTO . '">';
            $xml .= escape_xml_char($item->photo_url);
            $xml .= '</photo_url>';
        }
        $xml .= '</item>';
    } else {
        $xml .= '/>';
    }
    return $xml;
}


1;
