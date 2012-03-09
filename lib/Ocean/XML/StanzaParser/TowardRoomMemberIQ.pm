package Ocean::XML::StanzaParser::TowardRoomMemberIQ;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaParser';

use Ocean::Constants::IQType;
use Ocean::Constants::StanzaErrorType;
use Ocean::Constants::StanzaErrorCondition;
use Ocean::Constants::StreamErrorType;
use Ocean::Error;
use Ocean::Stanza::Incoming::TowardRoomMemberIQ;

sub parse {
    my ($class, $element) = @_;

    # XXX should die?
    my $to = $element->attr('to');
    return unless $to;

    my $to_jid = Ocean::JID->new($to);
    return unless $to_jid;

    my $room     = $to_jid->node;
    my $nickname = $to_jid->resource;

    my $id = $element->attr('id');
    return unless $id;

    my $type = $element->attr('type');
    return unless $type;

    my @children = $element->children;
    return unless @children > 0;

    my $first_child = $children[0][0];

    return Ocean::Stanza::Incoming::TowardRoomMemberIQ->new(
        $id, $type, $room, $nickname, "$first_child");
}

1;
