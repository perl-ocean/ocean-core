package Ocean::Registrar::DeliveryInfo;

use strict;
use warnings;

use Ocean::Constants::EventType;

my %INFO_MAP;

sub register {
    my ($class, $event_type, $info) = @_;
    $INFO_MAP{ $event_type } = $info;
}

sub get {
    my ($class, $event_type) = @_;
    return $INFO_MAP{ $event_type };
}

__PACKAGE__->register(
    Ocean::Constants::EventType::BOUND_JID,
        { 
            method => 'deliver_bound_jid', 
            class  => 'Ocean::Stanza::DeliveryRequest::BoundJID',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_MESSAGE,
        { 
            method => 'deliver_message', 
            class  => 'Ocean::Stanza::DeliveryRequest::ChatMessage',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::HTTP_AUTH_COMPLETION,
        { 
            method => 'deliver_http_auth_completion', 
            class  => 'Ocean::Stanza::DeliveryRequest::HTTPAuthCompletion',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::HTTP_AUTH_FAILURE,
        { 
            method => 'deliver_http_auth_failure', 
            class  => 'Ocean::Stanza::DeliveryRequest::HTTPAuthFailure',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::SASL_AUTH_COMPLETION,
        { 
            method => 'deliver_sasl_auth_completion', 
            class  => 'Ocean::Stanza::DeliveryRequest::SASLAuthCompletion',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::SASL_AUTH_FAILURE,
        { 
            method => 'deliver_sasl_auth_failure', 
            class  => 'Ocean::Stanza::DeliveryRequest::SASLAuthFailure',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_SASL_PASSWORD,
        { 
            method => 'deliver_sasl_password', 
            class  => 'Ocean::Stanza::DeliveryRequest::SASLPassword',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_PRESENCE,
        { 
            method => 'deliver_presence', 
            class  => 'Ocean::Stanza::DeliveryRequest::Presence',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_PUBSUB_EVENT,
        { 
            method => 'deliver_pubsub_event', 
            class  => 'Ocean::Stanza::DeliveryRequest::PubSubEvent',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_ROSTER,
        { 
            method => 'deliver_roster', 
            class  => 'Ocean::Stanza::DeliveryRequest::Roster',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_ROSTER_PUSH,
        { 
            method => 'deliver_roster_push', 
            class  => 'Ocean::Stanza::DeliveryRequest::RosterPush',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_UNAVAILABLE_PRESENCE,
        { 
            method => 'deliver_unavailable_presence', 
            class  => 'Ocean::Stanza::DeliveryRequest::UnavailablePresence',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_VCARD,
        { 
            method => 'deliver_vcard', 
            class  => 'Ocean::Stanza::DeliveryRequest::vCard',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_ROOM_INFO,
        { 
            method => 'deliver_disco_info', 
            class  => 'Ocean::Stanza::DeliveryRequest::DiscoInfo',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_ROOM_LIST,
        { 
            method => 'deliver_disco_items', 
            class  => 'Ocean::Stanza::DeliveryRequest::DiscoItems',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_ROOM_MEMBERS_LIST,
        {
            method => 'deliver_disco_items',
            class  => 'Ocean::Stanza::DeliveryRequest::DiscoItems',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_ROOM_INVITATION,
        { 
            method => 'deliver_room_invitation', 
            class  => 'Ocean::Stanza::DeliveryRequest::RoomInvitation',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_ROOM_INVITATION_DECLINE,
        { 
            method => 'deliver_room_invitation_decline', 
            class  => 'Ocean::Stanza::DeliveryRequest::RoomInvitationDecline',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_IQ_TOWARD_USER,
        { 
            method => 'deliver_iq_toward_user', 
            class  => 'Ocean::Stanza::DeliveryRequest::TowardUserIQ',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_IQ_TOWARD_ROOM_MEMBER,
        {
            method => 'deliver_iq_toward_room_member',
            class  => 'Ocean::Stanza::DeliveryRequest::TowardRoomMemberIQ',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_ROOM_MESSAGE,
        {
            method => 'deliver_room_message',
            class  => 'Ocean::Stanza::DeliveryRequest::RoomMessage',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_JINGLE_INFO,
        { 
            method => 'deliver_jingle_info', 
            class  => 'Ocean::Stanza::DeliveryRequest::JingleInfo',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_MESSAGE_ERROR,
        { 
            method => 'deliver_message_error', 
            class  => 'Ocean::Stanza::DeliveryRequest::MessageError',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_PRESENCE_ERROR,
        { 
            method => 'deliver_presence_error', 
            class  => 'Ocean::Stanza::DeliveryRequest::PresenceError',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::DELIVER_IQ_ERROR,
        { 
            method => 'deliver_iq_error', 
            class  => 'Ocean::Stanza::DeliveryRequest::IQError',
        },
);

1;
