package Ocean::XML::StanzaParser::DiscoInfo;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaParser';

use Ocean::Constants::IQType;
use Ocean::Constants::StanzaErrorType;
use Ocean::Constants::StanzaErrorCondition;
use Ocean::Constants::StreamErrorType;
use Ocean::Error;
use Ocean::XML::Namespaces qw(DISCO_INFO);
use Ocean::Stanza::Incoming::DiscoInfo;

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

    return Ocean::Stanza::Incoming::DiscoInfo->new($element->attr('id'));
}

1;
