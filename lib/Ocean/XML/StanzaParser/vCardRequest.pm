package Ocean::XML::StanzaParser::vCardRequest;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaParser';

use Ocean::Constants::IQType;
use Ocean::Constants::StanzaErrorType;
use Ocean::Constants::StanzaErrorCondition;
use Ocean::Constants::StreamErrorType;
use Ocean::Error;
use Ocean::JID;
use Ocean::XML::Namespaces qw(VCARD VCARD_PHOTO);
use Ocean::Stanza::Incoming::vCardRequest;

sub parse {
    my ($class, $element) = @_;

    # XXX should die?
    my $vcardElem = $element->get_first_element_ns(VCARD, q{vCard});
    return unless $vcardElem;

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


    my $to_jid;
    if ($to) {
        $to_jid = Ocean::JID->new($to);
        Ocean::Error::IQError->throw(
            id        => $element->attr('id'),
            type      => Ocean::Constants::StanzaErrorType::CANCEL,
            condition => Ocean::Constants::StanzaErrorCondition::JID_MALFORMED,
        ) unless $to_jid;
    }

    my $wantPhotoURL = $vcardElem->get_first_element_ns(VCARD_PHOTO, q{want-extval}) ? 1 : 0;

    return Ocean::Stanza::Incoming::vCardRequest->new($element->attr('id'), $to_jid, $wantPhotoURL);
}

1;
