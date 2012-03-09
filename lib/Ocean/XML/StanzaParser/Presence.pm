package Ocean::XML::StanzaParser::Presence;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaParser';

use List::MoreUtils qw(any);

use Ocean::Error;
use Ocean::Stanza::Incoming::Presence;
use Ocean::Util::XML qw(escape_xml_char unescape_xml_char);

sub parse {
    my ($class, $element) = @_;

    my $type = $element->attr('type');
    return if ($type && $type ne 'available');

    my $show_elem = $element->get_first_element('show');
    my $show = ($show_elem && $show_elem->text)
        ? $show_elem->text : 'chat';
    unless (any { $_ eq $show }
        qw(chat away xa dnd)) {
        Ocean::Error::ProtocolError->throw(
            message =>
                sprintf(q{unsupported presence@show '%s'}, $show));
    }

    my $status_elem = $element->get_first_element('status');
    my $status;
    $status = unescape_xml_char($status_elem->text)
        if ($status_elem && $status_elem->text);

    return Ocean::Stanza::Incoming::Presence->new($show, $status);
}

1;
