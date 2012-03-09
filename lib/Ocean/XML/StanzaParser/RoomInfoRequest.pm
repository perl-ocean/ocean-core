package Ocean::XML::StanzaParser::RoomInfoRequest;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaParser';

use Ocean::Constants::IQType;
use Ocean::Constants::StanzaErrorType;
use Ocean::Constants::StanzaErrorCondition;
use Ocean::Constants::StreamErrorType;
use Ocean::Error;
use Ocean::JID;
use Ocean::XML::Namespaces qw(DISCO_INFO);
use Ocean::Stanza::Incoming::RoomInfoRequest;

sub parse {
    my ($class, $element) = @_;

    # XXX should die?
    return unless $element->get_first_element_ns(DISCO_INFO, q{query});

    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::INVALID_ID,
    ) unless (
           $element->attr('id') 
        && $element->attr('id') ne ''
    );

    return unless (
           $element->attr('type')
        && $element->attr('type') eq Ocean::Constants::IQType::GET
    );

    my $to = $element->attr('to');
    my $to_jid = Ocean::JID->new($to);

    my $room_name = $to_jid->node;

    return Ocean::Stanza::Incoming::RoomInfoRequest->new(
        $element->attr('id'), $room_name);
}

1;
