package Ocean::Stanza::DeliveryRequestFormatter::XML::PubSubEvent;

use strict;
use warnings;

use Ocean::Stanza::DeliveryRequestFormatter::XML::PubSubEventItem;
use Ocean::Util::XML qw(escape_xml_char);
use Ocean::XML::Namespaces qw(PUBSUB_EV);

sub format {
    my ($class, $event) = @_;

    my $xml = sprintf('<message');

    if ($event->from) {
        $xml .= sprintf(q{ from="%s"}, 
            $event->from);
    }

    if ($event->to) {
        $xml .= sprintf(q{ to="%s"}, 
            $event->to);
    }
    $xml .= '<event xmlns="http://jabber.org/protocol/pubsub#event">';
    $xml .= sprintf(q{<event xmlns="%s">}, PUBSUB_EV);
    $xml .= sprintf(q{<items node="%s">}, 
        escape_xml_char($event->node));

    $xml .= Ocean::Stanza::DeliveryRequestFormatter::XML::PubSubEventItem->format($_)
        for @{ $event->items };

    $xml .= '</items></event></message>';

    return $xml;
}

1;
