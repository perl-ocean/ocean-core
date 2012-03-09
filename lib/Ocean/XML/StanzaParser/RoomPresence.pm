package Ocean::XML::StanzaParser::RoomPresence;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaParser';

use List::MoreUtils qw(any);

use Ocean::JID;
use Ocean::Error;
use Ocean::Util::XML qw(escape_xml_char unescape_xml_char);
use Ocean::Stanza::Incoming::RoomPresence;

sub parse {
    my ($class, $element) = @_;

    my $type = $element->attr('type');
    return if ($type && $type ne 'available');

    my $to = $element->attr('to');
    return unless $to;

    my $to_jid = Ocean::JID->new($to);
    return unless $to_jid;

    my $domain = $to_jid->domain;

    my $config = Ocean::Config->instance;
    return unless (   
           $domain 
        && $config->has_section('muc')
        && $config->get(muc => 'domain') eq $domain);

    my $room     = $to_jid->node;
    my $nickname = $to_jid->resource;

    return unless ($room && $nickname);

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

    return Ocean::Stanza::Incoming::RoomPresence->new(
        $room, $nickname, $show, $status);
}

1;
