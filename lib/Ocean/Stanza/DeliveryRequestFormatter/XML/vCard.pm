package Ocean::Stanza::DeliveryRequestFormatter::XML::vCard;

use strict;
use warnings;

use Ocean::XML::Namespaces qw(VCARD);
use Ocean::Util::XML qw(escape_xml_char);

sub format {
    my ($class, $vcard) = @_;
    my $xml = sprintf('<vCard xmlns="%s">', VCARD);
    if ($vcard->nickname) {
        $xml .= sprintf(q{<FN>%s</FN>},
            escape_xml_char($vcard->nickname)); 
    }
    if ($vcard->photo && $vcard->photo_content_type) {
        $xml .= '<PHOTO>';
        $xml .= sprintf(q{<TYPE>%s</TYPE>},
            escape_xml_char($vcard->photo_content_type));
        $xml .= '<BINVAL>';
        $xml .= $vcard->photo;
        $xml .= '</BINVAL>';
        $xml .= '</PHOTO>';
    }
    if ($vcard->photo_url) {

    }
    $xml .= '</vCard>';
}

1;
