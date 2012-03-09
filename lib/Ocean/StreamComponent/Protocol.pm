package Ocean::StreamComponent::Protocol;

use strict;
use warnings;

use Ocean::Error;
use Ocean::Constants::StreamErrorType;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        %args,
        _delegate => undef,
    }, $class;
    $self->_initialize();
    return $self;
}

sub _initialize {
    my $self = shift;
}

sub set_delegate {
    my ($self, $delegate) = @_;
    $self->{_delegate} = $delegate;
}

sub release {
    my $self = shift;
    delete $self->{_delegate} 
        if $self->{_delegate};
}

sub DESTROY {
    my $self = shift;
    $self->release();
}

# RECEIVED EVENT ( from client )
sub on_client_received_http_handshake {
    my ($self, $handshake) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_stream {
    my ($self, $attrs) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_message {
    my ($self, $to_jid, $message) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_presence {
    my ($self, $presence) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_bind_request {
    my ($self, $stream_id, $req) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_session_request {
    my ($self, $req) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_roster_request {
    my ($self, $sender_jid, $req) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_starttls {
    my $self = shift;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_negotiated_tls {
    my $self = shift;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_sasl_auth {
    my ($self, $auth) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_sasl_challenge_response {
    my ($self, $res) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_vcard_request {
    my ($self, $req) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_ping {
    my ($self, $ping) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_disco_info_request {
    my ($self, $req) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_disco_items_request {
    my ($self, $req) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_room_message {
    my ($self, $message) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_room_info_request {
    my ($self, $req) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_room_service_info_request {
    my ($self, $req) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_room_list_request {
    my ($self, $req) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_room_members_list_request {
    my ($self, $req) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_room_invitation {
    my ($self, $invitation) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_room_invitation_decline {
    my ($self, $decline) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_room_presence {
    my ($self, $presence) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_leave_room_presence {
    my ($self, $presence) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_jingle_info_request {
    my ($self, $req) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_iq_toward_user {
    my ($self, $req) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_client_received_iq_toward_room_member {
    my ($self, $req) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

# SERVER SUBSCRIBE EVENT
sub on_server_completed_sasl_auth {
    my ($self, $user_id, $username, $session_id) = @_;
    $self->throw_condition_mismatched_error(
        SASLAuthCompletion => 'on_server_completed_sasl_auth');
}

sub on_server_failed_sasl_auth {
    my $self = shift;
    $self->throw_condition_mismatched_error(
        SASLAuthFailure => 'on_server_failed_sasl_auth');
}

sub on_server_bound_jid {
    my ($self, $jid) = @_;
    $self->throw_condition_mismatched_error(
        BoundJID => 'on_server_bound_jid');
}

sub on_server_delivered_sasl_password {
    my ($self, $password) = @_;
    $self->throw_condition_mismatched_error(
        SASLPasswordDelivery => 'on_server_delivered_sasl_password');
}

sub on_server_delivered_message {
    my ($self, $message) = @_;
    $self->throw_condition_mismatched_error(
        MessageDelivery => 'on_server_delivered_message');
}

sub on_server_delivered_presence {
    my ($self, $iq) = @_;
    $self->throw_condition_mismatched_error(
        PresenceDelivery => 'on_server_delivered_presence');
}

sub on_server_delivered_unavailable_presence {
    my ($self, $iq) = @_;
    $self->throw_condition_mismatched_error(
        UnavailablePresenceDelivery => 'on_server_delivered_unavailable_presence');
}

sub on_server_delivered_pubsub_event {
    my ($self, $event) = @_;
    $self->throw_condition_mismatched_error(
        PubSubEventDelivery => 'on_server_delivered_pubsub_event');
}

sub on_server_delivered_iq_toward_user {
    my ($self, $id, $query) = @_;
    $self->throw_condition_mismatched_error(
        PubSubEventDelivery => 'on_server_delivered_iq_toward_user');
}

sub on_server_delivered_jingle_info {
    my ($self, $id, $info) = @_;
    $self->throw_condition_mismatched_error(
        PubSubEventDelivery => 'on_server_delivered_jingle_info');
}

sub on_server_delivered_roster {
    my ($self, $roster) = @_;
    $self->throw_condition_mismatched_error(
        RosterDelivery => 'on_server_delivered_roster');
}

sub on_server_delivered_roster_push {
    my ($self, $item) = @_;
    $self->throw_condition_mismatched_error(
        RosterPushDelivery => 'on_server_delivered_roster_push');
}

sub on_server_delivered_vcard {
    my ($self, $vcard) = @_;
    $self->throw_condition_mismatched_error(
        RosterDelivery => 'on_server_delivered_vcard');
}

sub on_server_delivered_disco_info {
    my ($self, $info) = @_;
    $self->throw_condition_mismatched_error(
        RosterDelivery => 'on_server_delivered_disco_info');
}

sub on_server_delivered_disco_items {
    my ($self, $items) = @_;
    $self->throw_condition_mismatched_error(
        RosterDelivery => 'on_server_delivered_disco_items');
}

sub on_server_delivered_room_invitation {
    my ($self, $invitation) = @_;
    $self->throw_condition_mismatched_error(
        RosterDelivery => 'on_server_delivered_room_invitation');
}

sub on_server_delivered_room_invitation_decline {
    my ($self, $decline) = @_;
    $self->throw_condition_mismatched_error(
        RosterDelivery => 'on_server_delivered_room_invitation_decline');
}

sub on_server_delivered_message_error {
    my ($self, $error) = @_;
    $self->throw_condition_mismatched_error(
        RosterDelivery => 'on_server_delivered_message_error');
}

sub on_server_delivered_presence_error {
    my ($self, $error) = @_;
    $self->throw_condition_mismatched_error(
        RosterDelivery => 'on_server_delivered_presence_error');
}

sub on_server_delivered_iq_error {
    my ($self, $error) = @_;
    $self->throw_condition_mismatched_error(
        RosterDelivery => 'on_server_delivered_iq_error');
}

sub on_server_completed_http_auth {
    my ($self, $user_id, $cookie) = @_;
    $self->throw_condition_mismatched_error(
        HTTPAuthCompletion => 'on_server_completed_http_auth');
}

sub on_server_failed_http_auth {
    my $self = shift;
    $self->throw_condition_mismatched_error(
        HTTPAuthFailure => 'on_server_failed_http_auth');
}

sub throw_condition_mismatched_error {
    my ($self, $event_name, $method_name) = @_;
    Ocean::Error::ConditionMismatchedServerEvent->throw(
        message => sprintf(q{<State::%s> @%s "%s" shouldn't be called.},
            $self->protocol_name, $event_name, $method_name)
    );
}

sub protocol_name {
    my $self = shift;
    my $module_name = ref($self) if ref $self;
    my @module_ns = split '::', $module_name;
    return @module_ns[scalar(@module_ns) - 1];
}

1;
