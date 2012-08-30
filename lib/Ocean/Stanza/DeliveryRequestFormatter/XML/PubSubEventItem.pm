package Ocean::Stanza::DeliveryRequestFormatter::XML::PubSubEventItem;

use strict;
use warnings;

use Ocean::Util::XML qw(escape_xml_char);
use Ocean::XML::Namespaces qw(ROSTER_PHOTO);

sub format {
    my ($class, $item) = @_;

    my $xml = '<item';
    $xml .= ' id="' . escape_xml_char($item->id) . '"';
    $xml .= '>';

    $xml .= sprintf(q{<%s xmlns="%s">}, 
        escape_xml_char($item->name),
        escape_xml_char($item->namespace));

    for my $key ( @{ $item->keys } ) {
        $xml .= sprintf(q{<%s>%s</%s>},
            escape_xml_char($key),
            escape_xml_char($item->param($key)),
            escape_xml_char($key)
        );
    }

    $xml .= sprintf(q{</%s>},
        escape_xml_char($item->name));
    $xml .= '</item>';
}

1;

