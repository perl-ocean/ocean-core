package Ocean::Stanza::DeliveryRequestFormatter::XML::DiscoInfo;

use strict;
use warnings;

use Ocean::XML::Namespaces qw(DISCO_INFO);
use Ocean::Util::XML qw(escape_xml_char);

sub format {
    my ($class, $info) = @_;

    my $xml = sprintf '<query xmlns="%s"', DISCO_INFO;

    my $internal = '';
    $internal .= sprintf('<identity category="%s" name="%s" type="%s"/>', 
        escape_xml_char($_->category), 
        escape_xml_char($_->name), 
        escape_xml_char($_->type)
    ) for @{ $info->identities };
    $internal .= sprintf('<feature var="%s"/>', escape_xml_char($_))
        for @{ $info->features };

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
