package Ocean::JSON::StanzaParserStore;

use strict;
use warnings;

use Ocean::Constants::EventType;

use Ocean::JSON::StanzaParser::Stream;
use Ocean::JSON::StanzaParser::ChatMessage;
use Ocean::JSON::StanzaParser::Presence;
use Ocean::JSON::StanzaParser::BindResource;
use Ocean::JSON::StanzaParser::Session;
use Ocean::JSON::StanzaParser::RosterRequest;
use Ocean::JSON::StanzaParser::vCardRequest;
use Ocean::JSON::StanzaParser::Ping;
use Ocean::JSON::StanzaParser::SASLAuth;

my %PARSER_STORE = ();

sub register_parser {
    my ($class, $event_type, $parser) = @_;
    $PARSER_STORE{ $event_type } = $parser;
}

sub get_parser {
    my ($class, $event_type) = @_;
    return $PARSER_STORE{ $event_type };
}

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::STREAM_INIT,
    Ocean::JSON::StanzaParser::Stream->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::SEND_MESSAGE,
    Ocean::JSON::StanzaParser::ChatMessage->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::BROADCAST_PRESENCE,
    Ocean::JSON::StanzaParser::Presence->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::BIND_REQUEST,
    Ocean::JSON::StanzaParser::BindResource->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::SESSION_REQUEST,
    Ocean::JSON::StanzaParser::Session->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::SASL_AUTH_REQUEST,
    Ocean::JSON::StanzaParser::SASLAuth->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::ROSTER_REQUEST,
    Ocean::JSON::StanzaParser::RosterRequest->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::VCARD_REQUEST,
    Ocean::JSON::StanzaParser::vCardRequest->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::PING,
    Ocean::JSON::StanzaParser::Ping->new,
);

1;
