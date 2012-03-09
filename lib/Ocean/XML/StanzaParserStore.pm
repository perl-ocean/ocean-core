package Ocean::XML::StanzaParserStore;

use strict;
use warnings;

use Ocean::Constants::EventType;

use Ocean::XML::StanzaParser::ChatMessage;
use Ocean::XML::StanzaParser::RoomMessage;
use Ocean::XML::StanzaParser::Presence;
use Ocean::XML::StanzaParser::BindResource;
use Ocean::XML::StanzaParser::Session;
use Ocean::XML::StanzaParser::RosterRequest;
use Ocean::XML::StanzaParser::vCardRequest;
use Ocean::XML::StanzaParser::Ping;
use Ocean::XML::StanzaParser::DiscoInfo;
use Ocean::XML::StanzaParser::DiscoItems;
use Ocean::XML::StanzaParser::SASLAuth;
use Ocean::XML::StanzaParser::SASLChallengeResponse;
use Ocean::XML::StanzaParser::TowardUserIQ;
use Ocean::XML::StanzaParser::TowardRoomMemberIQ;
use Ocean::XML::StanzaParser::RoomInfoRequest;
use Ocean::XML::StanzaParser::RoomListRequest;
use Ocean::XML::StanzaParser::RoomMembersListRequest;
use Ocean::XML::StanzaParser::RoomServiceInfoRequest;
use Ocean::XML::StanzaParser::RoomInvitation;
use Ocean::XML::StanzaParser::RoomInvitationDecline;
use Ocean::XML::StanzaParser::RoomPresence;
use Ocean::XML::StanzaParser::LeaveRoomPresence;
use Ocean::XML::StanzaParser::JingleInfoRequest;

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
    Ocean::Constants::EventType::SEND_MESSAGE,
    Ocean::XML::StanzaParser::ChatMessage->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::SEND_ROOM_MESSAGE,
    Ocean::XML::StanzaParser::RoomMessage->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::BROADCAST_PRESENCE,
    Ocean::XML::StanzaParser::Presence->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::BIND_REQUEST,
    Ocean::XML::StanzaParser::BindResource->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::SESSION_REQUEST,
    Ocean::XML::StanzaParser::Session->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::ROSTER_REQUEST,
    Ocean::XML::StanzaParser::RosterRequest->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::VCARD_REQUEST,
    Ocean::XML::StanzaParser::vCardRequest->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::PING,
    Ocean::XML::StanzaParser::Ping->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::DISCO_INFO_REQUEST,
    Ocean::XML::StanzaParser::DiscoInfo->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::DISCO_ITEMS_REQUEST,
    Ocean::XML::StanzaParser::DiscoItems->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::ROOM_INFO_REQUEST,
    Ocean::XML::StanzaParser::RoomInfoRequest->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::ROOM_LIST_REQUEST,
    Ocean::XML::StanzaParser::RoomListRequest->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::ROOM_MEMBERS_LIST_REQUEST,
    Ocean::XML::StanzaParser::RoomMembersListRequest->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::ROOM_SERVICE_INFO_REQUEST,
    Ocean::XML::StanzaParser::RoomServiceInfoRequest->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::ROOM_INVITATION,
    Ocean::XML::StanzaParser::RoomInvitation->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::ROOM_INVITATION_DECLINE,
    Ocean::XML::StanzaParser::RoomInvitationDecline->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::ROOM_PRESENCE,
    Ocean::XML::StanzaParser::RoomPresence->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::LEAVE_ROOM_PRESENCE,
    Ocean::XML::StanzaParser::LeaveRoomPresence->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::JINGLE_INFO_REQUEST,
    Ocean::XML::StanzaParser::JingleInfoRequest->new,
);

__PACKAGE__->register_parser(
    Ocean::Constants::EventType::SEND_IQ_TOWARD_USER,
    Ocean::XML::StanzaParser::TowardUserIQ->new,
);
__PACKAGE__->register_parser(
    Ocean::Constants::EventType::SEND_IQ_TOWARD_ROOM_MEMBER,
    Ocean::XML::StanzaParser::TowardRoomMemberIQ->new,
);

1;
