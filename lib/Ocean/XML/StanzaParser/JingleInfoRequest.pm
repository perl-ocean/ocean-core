package Ocean::XML::StanzaParser::JingleInfoRequest;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaParser';

use Ocean::Constants::IQType;
use Ocean::Constants::StanzaErrorType;
use Ocean::Constants::StanzaErrorCondition;
use Ocean::Constants::StreamErrorType;
use Ocean::Error;
use Ocean::XML::Namespaces qw(JINGLE_INFO);
use Ocean::Stanza::Incoming::JingleInfoRequest;

use Log::Minimal;

sub parse {
    my ($class, $element) = @_;

    # XXX should die?
    my $request_elem = $element->get_first_element_ns(JINGLE_INFO, q{query});
    return unless $request_elem;

     debugf('JingleInfoReuqest: InvalidID') unless (
           $element->attr('id') 
        && $element->attr('id') ne ''
    );
    debugf('JingleInfoRequest: InvalidType') unless (
           $element->attr('type') 
        && $element->attr('type') eq Ocean::Constants::IQType::GET
    );

    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::INVALID_ID,
    ) unless (
           $element->attr('id') 
        && $element->attr('id') ne ''
    );

    Ocean::Error::IQError->throw(
        id        => $element->attr('id'),
        type      => Ocean::Constants::StanzaErrorType::CANCEL,
        condition => Ocean::Constants::StanzaErrorCondition::BAD_REQUEST,
    ) unless (
           $element->attr('type') 
        && $element->attr('type') eq Ocean::Constants::IQType::GET
    );

    return Ocean::Stanza::Incoming::JingleInfoRequest->new($element->attr('id'));
}

1;
