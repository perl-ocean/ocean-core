package Ocean::Stanza::DeliveryRequestFormatter::XML::DiscoItems;

use strict;
use warnings;

use Ocean::XML::Namespaces qw(DISCO_ITEMS);
use Ocean::Util::XML qw(escape_xml_char);

sub format {
    my ($class, $items) = @_;

    my $xml = sprintf '<query xmlns="%s"', DISCO_ITEMS;

    my $internal = '';
    $internal .= sprintf('<item jid="%s" name="%s"/>', 
        escape_xml_char($_->jid), 
        escape_xml_char($_->name), 
    ) for @{ $items->items };

    if ($internal) {
        $xml .= '>';
        $xml .= $internal;
        $xml .= '</query>';
    } else {
        $xml .= '/>';
    }
    return $xml;
}

1;
