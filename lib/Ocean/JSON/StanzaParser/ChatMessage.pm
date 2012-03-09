package Ocean::JSON::StanzaParser::ChatMessage;

use strict;
use warnings;

use parent 'Ocean::JSON::StanzaParser';
use Ocean::Error;
use Ocean::JID;
use Ocean::Constants::StanzaErrorType;
use Ocean::Constants::StanzaErrorCondition;
use Ocean::Stanza::Incoming::ChatMessage;

sub parse {
    my ($self, $obj) = @_;

    return unless exists $obj->{message};

    my $message_obj = $obj->{message};

    my $to = $message_obj->{to};
    my $to_jid = Ocean::JID->new($to);

    Ocean::Error::MessageError->throw(
        type      => Ocean::Constants::StanzaErrorType::CANCEL,
        condition => Ocean::Constants::StanzaErrorCondition::JID_MALFORMED,
        message   => sprintf(q{invalid jid, "%s"}, $to)
    ) unless $to_jid;

    my $body    = $message_obj->{body}   || '';
    my $thread  = $message_obj->{thread} || '';

    my $chat_message = 
        Ocean::Stanza::Incoming::ChatMessage->new($to_jid, $body, $thread);
    return $chat_message;
}

1;
