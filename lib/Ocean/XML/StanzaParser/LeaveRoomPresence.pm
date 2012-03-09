package Ocean::XML::StanzaParser::LeaveRoomPresence;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaParser';

use List::MoreUtils qw(any);

use Ocean::JID;
use Ocean::Error;
use Ocean::Util::XML qw(escape_xml_char unescape_xml_char);
use Ocean::Stanza::Incoming::LeaveRoomPresence;

sub parse {
    my ($class, $element) = @_;

    my $type = $element->attr('type');
    return unless ($type && $type eq 'unavailable');

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

    return Ocean::Stanza::Incoming::LeaveRoomPresence->new(
        $room, $nickname);
}

1;
