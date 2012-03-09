package Ocean::Registrar::EventCategory;

use strict;
use warnings;

use Ocean::Constants::EventType;

my %INFO_MAP;

sub register {
    my ($class, $event_type, $category) = @_;
    $INFO_MAP{ $event_type } = $category;
}

sub get {
    my ($class, $event_type) = @_;
    return $INFO_MAP{ $event_type };
}

__PACKAGE__->register(
    Ocean::Constants::EventType::TOO_MANY_AUTH_ATTEMPT, 
        'authen',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::SASL_AUTH_REQUEST, 
        'authen',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::SASL_PASSWORD_REQUEST, 
        'authen',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::SASL_SUCCESS_NOTIFICATION, 
        'authen',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::HTTP_AUTH_REQUEST, 
        'authen',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::BIND_REQUEST, 
        'connection',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::SEND_MESSAGE, 
        'message',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::BROADCAST_PRESENCE, 
        'connection',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::BROADCAST_INITIAL_PRESENCE, 
        'connection',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::BROADCAST_UNAVAILABLE_PRESENCE, 
        'connection',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::SILENT_DISCONNECTION, 
        'connection',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::ROSTER_REQUEST, 
        'people',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::VCARD_REQUEST, 
        'people',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::SEND_ROOM_MESSAGE, 
        'room',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::ROOM_INFO_REQUEST, 
        'room',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::ROOM_LIST_REQUEST, 
        'room',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::ROOM_MEMBERS_LIST_REQUEST, 
        'room',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::ROOM_INVITATION, 
        'room',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::ROOM_INVITATION_DECLINE, 
        'room',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::ROOM_PRESENCE, 
        'room',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::LEAVE_ROOM_PRESENCE, 
        'room',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::NODE_INIT, 
        'node',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::NODE_TIMER_REPORT, 
        'node',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::NODE_EXIT, 
        'node',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::WORKER_INIT, 
        'worker',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::WORKER_EXIT, 
        'worker',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::SEND_IQ_TOWARD_ROOM_MEMBER, 
        'room',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::PUBLISH_EVENT, 
        'pubsub',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::SEND_IQ_TOWARD_USER, 
        'p2p',
);
__PACKAGE__->register(
    Ocean::Constants::EventType::JINGLE_INFO_REQUEST, 
        'p2p',
);
1;
