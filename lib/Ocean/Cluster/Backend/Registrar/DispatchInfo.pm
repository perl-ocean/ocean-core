package Ocean::Cluster::Backend::Registrar::DispatchInfo;

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
    Ocean::Constants::EventType::TOO_MANY_AUTH_ATTEMPT, 
        { 
            args_class => 'Ocean::HandlerArgs::TooManyAuthAttempt',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::SASL_AUTH_REQUEST, 
        { 
            args_class => 'Ocean::HandlerArgs::SASLAuthRequest',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::SASL_PASSWORD_REQUEST, 
        { 
            args_class => 'Ocean::HandlerArgs::SASLPasswordRequest',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::SASL_SUCCESS_NOTIFICATION, 
        { 
            args_class => 'Ocean::HandlerArgs::SASLSuccessNotification',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::HTTP_AUTH_REQUEST, 
        { 
            args_class => 'Ocean::HandlerArgs::HTTPAuthRequest',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::BIND_REQUEST, 
        { 
            args_class => 'Ocean::HandlerArgs::BindRequest',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::SEND_MESSAGE, 
        { 
            args_class => 'Ocean::HandlerArgs::Message',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::BROADCAST_PRESENCE, 
        { 
            args_class => 'Ocean::HandlerArgs::Presence',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::BROADCAST_INITIAL_PRESENCE, 
        { 
            args_class => 'Ocean::HandlerArgs::InitialPresence',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::BROADCAST_UNAVAILABLE_PRESENCE, 
        { 
            args_class => 'Ocean::HandlerArgs::UnavailablePresence',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::SILENT_DISCONNECTION, 
        { 
            args_class => 'Ocean::HandlerArgs::SilentDisconnection',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::ROSTER_REQUEST, 
        { 
            args_class => 'Ocean::HandlerArgs::RosterRequest',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::VCARD_REQUEST, 
        { 
            args_class => 'Ocean::HandlerArgs::vCardRequest',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::PUBLISH_EVENT, 
        { 
            args_class => 'Ocean::HandlerArgs::PubSubEvent',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::NODE_INIT, 
        { 
            args_class => 'Ocean::HandlerArgs::NodeInitialization',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::NODE_TIMER_REPORT, 
        { 
            args_class => 'Ocean::HandlerArgs::NodeTimerReport',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::NODE_EXIT, 
        { 
            args_class => 'Ocean::HandlerArgs::NodeExit',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::SEND_IQ_TOWARD_USER, 
        { 
            args_class => 'Ocean::HandlerArgs::TowardUserIQ',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::ROOM_INFO_REQUEST, 
        { 
            args_class => 'Ocean::HandlerArgs::RoomInfoRequest',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::ROOM_LIST_REQUEST, 
        { 
            args_class => 'Ocean::HandlerArgs::RoomListRequest',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::ROOM_MEMBERS_LIST_REQUEST, 
        { 
            args_class => 'Ocean::HandlerArgs::RoomMembersListRequest',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::ROOM_INVITATION, 
        { 
            args_class => 'Ocean::HandlerArgs::RoomInvitation',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::ROOM_INVITATION_DECLINE, 
        { 
            args_class => 'Ocean::HandlerArgs::RoomInvitationDecline',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::SEND_ROOM_MESSAGE, 
        { 
            args_class => 'Ocean::HandlerArgs::RoomMessage',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::ROOM_PRESENCE,
        {
            args_class => 'Ocean::HandlerArgs::RoomPresence',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::LEAVE_ROOM_PRESENCE,
        {
            args_class => 'Ocean::HandlerArgs::LeaveRoomPresence',
        },
);
__PACKAGE__->register(
    Ocean::Constants::EventType::SEND_IQ_TOWARD_ROOM_MEMBER,
        {
            args_class => 'Ocean::HandlerArgs::TowardRoomMemberIQ',
        },
);
1;
