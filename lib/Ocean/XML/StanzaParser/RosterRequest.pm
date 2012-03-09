package Ocean::XML::StanzaParser::RosterRequest;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaParser';

use Ocean::Constants::IQType;
use Ocean::Constants::StanzaErrorType;
use Ocean::Constants::StanzaErrorCondition;
use Ocean::Constants::StreamErrorType;
use Ocean::Error;
use Ocean::XML::Namespaces qw(ROSTER BIND ROSTER_PHOTO);
use Ocean::Stanza::Incoming::RosterRequest;

use Log::Minimal;

sub parse {
    my ($class, $element) = @_;

    # XXX should die?
    my $roster_elem =  $element->get_first_element_ns(ROSTER, q{query});
    return unless $roster_elem;

     debugf('RosterReuqest: InvalidID') unless (
           $element->attr('id') 
        && $element->attr('id') ne ''
    );
    debugf('RosterRequest: InvalidType') unless (
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

    my $want_photo_URL = $roster_elem->get_first_element_ns(ROSTER_PHOTO, q{want-extval}) ? 1 : 0;

    return Ocean::Stanza::Incoming::RosterRequest->new(
        $element->attr('id'), $want_photo_URL);
}

1;
