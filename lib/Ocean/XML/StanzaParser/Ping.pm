package Ocean::XML::StanzaParser::Ping;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaParser';

use Ocean::Constants::IQType;
use Ocean::Constants::StanzaErrorType;
use Ocean::Constants::StanzaErrorCondition;
use Ocean::Constants::StreamErrorType;
use Ocean::Error;
use Ocean::XML::Namespaces qw(PING);
use Ocean::Stanza::Incoming::Ping;

sub parse {
    my ($class, $element) = @_;

    # XXX should die?
    return unless $element->get_first_element_ns(PING, q{ping});

    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::INVALID_ID,
    ) unless (
           $element->attr('id') 
        && $element->attr('id') ne ''
    );

    # TODO
    # if type is result, it is pong.
    Ocean::Error::IQError->throw(
        id        => $element->attr('id'),
        type      => Ocean::Constants::StanzaErrorType::CANCEL,
        condition => Ocean::Constants::StanzaErrorCondition::BAD_REQUEST,
    ) unless (
           $element->attr('type')
        && $element->attr('type') eq Ocean::Constants::IQType::GET
    );

    return Ocean::Stanza::Incoming::Ping->new($element->attr('id'));
}

1;
