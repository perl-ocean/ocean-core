package Ocean::Stanza::DeliveryRequestFormatter::XML::Roster;

use strict;
use warnings;

use Ocean::Stanza::DeliveryRequestFormatter::XML::RosterItem;

sub format {
    my ($class, $roster) = @_;
    my $xml; $xml .= Ocean::Stanza::DeliveryRequestFormatter::XML::RosterItem->format($_)
        for @{ $roster->items };
    return $xml;
}

1;
