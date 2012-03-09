package Ocean::XML::StanzaParser::RoomInvitation;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaParser';

use Ocean::Error;
use Ocean::JID;
use Ocean::Config;
use Ocean::Constants::MessageType;
use Ocean::Constants::StanzaErrorCondition;
use Ocean::Constants::StanzaErrorType;
use Ocean::Util::XML qw(unescape_xml_char);
use Ocean::XML::Namespaces qw(MUC_USER);

use Ocean::Stanza::Incoming::RoomInvitation;

sub parse {
    my ($class, $element) = @_;

    my $to = $element->attr('to');

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

    my $domain = $to_jid->domain;

    my $config = Ocean::Config->instance;
    return unless (   
           $domain 
        && $config->has_section('muc')
        && $config->get(muc => 'domain') eq $domain);

    my $room = $to_jid->node;
    return unless $room;

    my $x = $element->get_first_element_ns(MUC_USER, 'x');
    return unless $x;

    my $invite = $x->get_first_element('invite');
    return unless $invite;

    my $invite_to = $invite->attr('to');
    my $invite_to_jid = Ocean::JID->new($invite_to);
    return unless $invite_to_jid;
    my $user = $invite_to_jid->node;
    return unless $user;

    my $reason_elem = $invite->get_first_element('reason');
    my $reason = $reason_elem ? $reason_elem->text : '';

    my $continue_elem = $invite->get_first_element('continue');
    my $thread = ($continue_elem && $continue_elem->attr('thread'))
        ? $continue_elem->attr('thread') : undef;

    return Ocean::Stanza::Incoming::RoomInvitation->new(
        $room, $invite_to_jid, $reason, $thread);
}

1;
