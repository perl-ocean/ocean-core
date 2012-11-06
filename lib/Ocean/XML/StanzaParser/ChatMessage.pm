package Ocean::XML::StanzaParser::ChatMessage;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaParser';

use Ocean::Error;
use Ocean::JID;
use Ocean::Constants::MessageType;
use Ocean::Constants::StanzaErrorCondition;
use Ocean::Constants::StanzaErrorType;
use Ocean::Constants::ChatState;
use Ocean::HTML::Sanitizer;
use Ocean::Stanza::Incoming::ChatMessage;
use Ocean::Util::XML qw(unescape_xml_char);
use Ocean::XML::Namespaces qw(CHAT_STATES XHTML_IM XHTML);

use Log::Minimal;

sub parse {
    my ($class, $element) = @_;

    my $type = $element->attr('type') || Ocean::Constants::MessageType::CHAT;
    return unless $type eq Ocean::Constants::MessageType::CHAT;

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

    my $body_elem = $element->get_first_element('body');
    my $body = ($body_elem && defined $body_elem->text)
        ? unescape_xml_char($body_elem->text) : '';

    my $thr_elem = $element->get_first_element('thread');
    my $thread = ($thr_elem && $thr_elem->text)
        ? unescape_xml_char($thr_elem->text) : '';

    my $state = '';
    for my $state_name ( 
        Ocean::Constants::ChatState::ACTIVE, 
        Ocean::Constants::ChatState::INACTIVE, 
        Ocean::Constants::ChatState::COMPOSING, 
        Ocean::Constants::ChatState::PAUSED, 
        Ocean::Constants::ChatState::GONE, 
        ) {
        my $found = $element->get_first_element_ns(CHAT_STATES, $state_name);
        if ($found) {
            $state = $state_name;
            last;
        }
    }

    my $xhtml = '';
    my $html_elem = $element->get_first_element_ns(XHTML_IM, 'html');
    if ($html_elem) {
        my $body_elem = $html_elem->get_first_element_ns(XHTML, 'body');
        $xhtml = Ocean::HTML::Sanitizer->sanitize($body_elem->as_string)
            if $body;
    }

    return Ocean::Stanza::Incoming::ChatMessage->new(
        $to_jid, $body, $thread, $state, $xhtml);
}

1;
