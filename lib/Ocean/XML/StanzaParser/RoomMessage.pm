package Ocean::XML::StanzaParser::RoomMessage;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaParser';

use Ocean::Error;
use Ocean::JID;
use Ocean::Config;
use Ocean::Constants::MessageType;
use Ocean::Constants::StanzaErrorCondition;
use Ocean::Constants::StanzaErrorType;
use Ocean::Stanza::Incoming::RoomMessage;
use Ocean::Util::XML qw(unescape_xml_char);
use Ocean::XML::Namespaces qw(XHTML_IM XHTML);

sub parse {
    my ($class, $element) = @_;

    my $type = $element->attr('type') || Ocean::Constants::MessageType::CHAT;
    return unless $type eq Ocean::Constants::MessageType::GROUPCHAT;

    my $to =$element->attr('to');

    Ocean::Error::MessageError->throw(
        type      => Ocean::Constants::StanzaErrorType::CANCEL,
        condition => Ocean::Constants::StanzaErrorCondition::BAD_REQUEST,
        message   => q{message@to not found},
    ) unless $to;

    # XXX accept messages which 'to' is not user?
    my $to_jid = Ocean::JID->new($to);

    Ocean::Error::MessageError->throw(
        type      => Ocean::Constants::StanzaErrorType::CANCEL,
        condition => Ocean::Constants::StanzaErrorCondition::JID_MALFORMED,
        message   => sprintf(q{invalid jid, "%s"}, $to)
    ) unless $to_jid;

    # XXX check domain which included to_jid here?
    #if (!$to_jid->is_host && $to_jid->domain ne Ocean::Config->instance->get('server','domain')) {
    #    Ocean::Error::MessageError->throw(
    #        type      => Ocean::Constants::StanzaErrorType::CANCEL,
    #        condition => Ocean::Constants::StanzaErrorCondition::JID_MALFORMED,
    #    );
    #}
    my $domain = $to_jid->domain;

    my $config = Ocean::Config->instance;
    return unless (   
           $domain 
        && $config->has_section('muc')
        && $config->get(muc => 'domain') eq $domain);

    my $room = $to_jid->node;
    return unless $room;

    # XXX support direct group chat message?
    # my $nickname = $to_jid->resource;

    my $body_elem = $element->get_first_element('body');
    my $body = ($body_elem && $body_elem->text)
        ? unescape_xml_char($body_elem->text) : '';

    my $subject_elem = $element->get_first_element('subject');
    my $subject = ($subject_elem && $subject_elem->text)
        ? unescape_xml_char($subject_elem->text) : '';

    my $xhtml = '';
    my $html_elem = $element->get_first_element_ns(XHTML_IM, 'html');
    if ($html_elem) {
        my $body_elem = $html_elem->get_first_element_ns(XHTML, 'body');
        $xhtml = Ocean::HTML::Sanitizer->sanitize($body_elem->as_string)
            if $body;
    }

    return Ocean::Stanza::Incoming::RoomMessage->new(
        $room, $body, $subject, $xhtml);
}

1;
