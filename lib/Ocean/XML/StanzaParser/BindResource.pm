package Ocean::XML::StanzaParser::BindResource;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaParser';

use Ocean::Stanza::Incoming::BindResource;
use Ocean::XML::Namespaces qw(ROSTER BIND);
use Ocean::Constants::IQType;
use Ocean::Constants::StanzaErrorType;
use Ocean::Constants::StanzaErrorCondition;
use Ocean::Constants::StreamErrorType;
use Ocean::Error;

sub parse {
    my ($class, $element) = @_;
    # XXX should die?
    return unless $element->get_first_element_ns(BIND, q{bind});

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
        && $element->attr('type') eq Ocean::Constants::IQType::SET
    );

    my $bind_elem = $element->get_first_element_ns(BIND, q{bind});

    # XXX IGNORE
    #my $resource_elem = $bind_elem->get_first_element(q{resource});
    #my $resource = ($resource_elem && $resource_elem->text) 
    #    ? $resource_elem->text : undef;
    
    return Ocean::Stanza::Incoming::BindResource->new($element->attr('id'));
}

1;
