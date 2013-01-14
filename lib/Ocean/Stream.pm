package Ocean::Stream;

use strict;
use warnings;

use Try::Tiny;
use Log::Minimal;

use Ocean::Config;
use Ocean::Constants::ProtocolPhase;
use Ocean::Error;
use Ocean::JID;
use Ocean::StreamComponent::ProtocolFactory;
use Ocean::Util::String;
use Ocean::Util::TLS;

use constant {
    ID           => 0,
    CLIENT_IO    => 1,
    SERVER       => 2, # StreamManager
    PROTOCOL     => 3,
    BOUND_JID    => 4,
    USER_ID      => 5,
    STATUS       => 6,
};

use constant {
    STATUS_INIT          => 0,
    STATUS_AUTHENTICATED => 1,
    STATUS_BOUND         => 2,
    STATUS_AVAILABLE     => 3,
};

sub new {
    my ($class, %args) = @_;
    my $self = bless [
        $args{id},   # Stream ID
        $args{io},   # CLIENT_IO Component
        undef,       # SERVER
        undef,       # PROTOCOL
        undef,       # BOUND_JID
        undef,       # USER_ID
        STATUS_INIT, # STATUS
    ], $class;

    $self->[CLIENT_IO]->set_delegate($self);

    my $protocol = defined $args{initial_protocol} 
            ? $args{initial_protocol} 
            : Ocean::Util::TLS::require_starttls()
                ? Ocean::Constants::ProtocolPhase::TLS_STREAM 
                : Ocean::Constants::ProtocolPhase::SASL_STREAM;

    $self->[PROTOCOL] = 
        Ocean::StreamComponent::ProtocolFactory->get_protocol($protocol);
    $self->[PROTOCOL]->set_delegate($self);

    return $self;
}

sub set_delegate {
    my ($self, $server) = @_;
    $self->[SERVER] = $server;
}

sub host { 
    my $self = shift;
    $self->[CLIENT_IO]->host(); 
}

sub port { 
    my $self = shift;
    $self->[CLIENT_IO]->port(); 
}

sub id {
    my $self = shift;
    return $self->[ID];
}

sub bound_jid {
    my $self = shift;
    return $self->[BOUND_JID];
}

sub user_id {
    my $self = shift;
    return $self->[USER_ID];
}

sub is_bound {
    my $self = shift;
    return $self->[STATUS] >= STATUS_BOUND;
    #return $self->[BOUND_JID] ? 1 : 0;
}

sub is_authenticated {
    my $self = shift;
    return $self->[STATUS] >= STATUS_AUTHENTICATED;
}

sub is_available {
    my $self = shift;
    return $self->[STATUS] == STATUS_AVAILABLE;
}

sub is_closing {
    my $self = shift;
    return 1 unless $self->[CLIENT_IO];
    return $self->[CLIENT_IO]->is_closing();
}

sub close {
    my $self = shift;
    $self->[CLIENT_IO]->close();
}

sub close_with_ending_stream {
    my ($self, $error_type, $error_msg) = @_;
    $self->[CLIENT_IO]->close_with_ending_stream(
        $error_type, $error_msg) if $self->[CLIENT_IO];
}

=head2 CLIENT_IO EVENTS

=cut

sub on_io_received_unavailable_presence {
    my $self = shift;
    $self->[CLIENT_IO]->close();
}

=head3 CLIENT_IO -> SERVER

=cut

sub on_io_closed {
    my $self = shift;

    # notify to handler
    # - adust connection map table
    if ($self->is_available) {
        debugf( sprintf '<Stream:JID:%s> <IO> @closed unavailable presence',
            $self->bound_jid->node);
        $self->[SERVER]->on_stream_handle_unavailable_presence(
            $self->bound_jid);
    } elsif ($self->is_authenticated) {
        debugf( sprintf '<Stream:JID:%s> <IO> @closed silent disconnection',
            $self->bound_jid->node);
        $self->[SERVER]->on_stream_handle_silent_disconnection(
            $self->bound_jid);
    }

    # for connection management
    # - release stream object memory
    # - update statistics report
    # - count down exit guard
    if ($self->is_bound) {
        debugf( sprintf '<Stream:JID:%s> <IO> @closed bound closed',
            $self->bound_jid->node);
        $self->[SERVER]->on_stream_bound_closed($self->bound_jid, $self->id);
    } else {
        debugf( sprintf '<Stream:FD:%s> <IO> @closed unbound closed',
            $self->id);
        $self->[SERVER]->on_stream_unbound_closed($self->id);
    }
}

=head3 CLIENT_IO -> PROTOCOL

=cut

sub on_io_received_http_handshake {
    my ($self, $params) = @_;
    $self->[PROTOCOL]->on_client_received_http_handshake($params);
}

sub on_io_received_stream {
    my ($self, $attrs) = @_;
    $self->[PROTOCOL]->on_client_received_stream($attrs);
}

sub on_io_received_message {
    my ($self, $message) = @_;
    $self->[PROTOCOL]->on_client_received_message($message);
}

sub on_io_received_presence {
    my ($self, $presence) = @_;
    $self->[PROTOCOL]->on_client_received_presence($presence);
}

sub on_io_received_starttls {
    my $self = shift;
    $self->[PROTOCOL]->on_client_received_starttls();
}

sub on_io_received_sasl_auth {
    my ($self, $auth) = @_;
    $self->[PROTOCOL]->on_client_received_sasl_auth($auth);
}

sub on_io_received_sasl_challenge_response {
    my ($self, $res) = @_;
    $self->[PROTOCOL]->on_client_received_sasl_challenge_response($res);
}

sub on_io_received_bind_request {
    my ($self, $req) = @_;
    $self->[PROTOCOL]->on_client_received_bind_request($req);
}

sub on_io_received_session_request {
    my ($self, $req) = @_;
    $self->[PROTOCOL]->on_client_received_session_request($req);
}

sub on_io_received_roster_request {
    my ($self, $req) = @_;
    $self->[PROTOCOL]->on_client_received_roster_request($req);
}

sub on_io_received_vcard_request {
    my ($self, $req) = @_;
    unless ($req->to) {
        $req->to( $self->bound_jid );
    }
    $self->[PROTOCOL]->on_client_received_vcard_request($req);
}

sub on_io_received_ping {
    my ($self, $ping) = @_;
    $self->[PROTOCOL]->on_client_received_ping($ping);
}

sub on_io_received_disco_info_request {
    my ($self, $req) = @_;

    infof('<Stream:JID:%s> @disco_info_request', $self->bound_jid->node);

    $self->[PROTOCOL]->on_client_received_disco_info_request($req);
}

sub on_io_received_disco_items_request {
    my ($self, $req) = @_;

    infof('<Stream:JID:%s> @disco_item_request', $self->bound_jid->node);

    $self->[PROTOCOL]->on_client_received_disco_items_request($req);
}

sub on_io_received_room_message {
    my ($self, $message) = @_;
    $self->[PROTOCOL]->on_client_received_room_message($message);
}

sub on_io_received_room_info_request {
    my ($self, $req) = @_;
    $self->[PROTOCOL]->on_client_received_room_info_request($req);
}

sub on_io_received_room_service_info_request {
    my ($self, $req) = @_;

    infof('<Stream:JID:%s> @room_service_info_request', $self->bound_jid->node);

    $self->[PROTOCOL]->on_client_received_room_service_info_request($req);
}

sub on_io_received_room_list_request {
    my ($self, $req) = @_;
    $self->[PROTOCOL]->on_client_received_room_list_request($req);
}

sub on_io_received_room_members_list_request {
    my ($self, $req) = @_;
    $self->[PROTOCOL]->on_client_received_room_members_list_request($req);
}

sub on_io_received_room_invitation {
    my ($self, $invitation) = @_;
    $self->[PROTOCOL]->on_client_received_room_invitation($invitation);
}

sub on_io_received_room_invitation_decline {
    my ($self, $decline) = @_;
    $self->[PROTOCOL]->on_client_received_room_invitation_decline($decline);
}

sub on_io_received_room_presence {
    my ($self, $presence) = @_;
    $self->[PROTOCOL]->on_client_received_room_presence($presence);
}

sub on_io_received_leave_room_presence {
    my ($self, $presence) = @_;
    $self->[PROTOCOL]->on_client_received_leave_room_presence($presence);
}

sub on_io_received_jingle_info_request {
    my ($self, $req) = @_;
    $self->[PROTOCOL]->on_client_received_jingle_info_request($req);
}

sub on_io_received_iq_toward_user {
    my ($self, $req) = @_;
    $self->[PROTOCOL]->on_client_received_iq_toward_user($req);
}

sub on_io_received_iq_toward_room_member {
    my ($self, $req) = @_;
    $self->[PROTOCOL]->on_client_received_iq_toward_room_member($req);
}

sub on_io_negotiated_tls {
    my $self = shift;
    $self->[PROTOCOL]->on_client_negotiated_tls();
}

=head2 PROTOCOL EVENTS

=cut

sub on_protocol_step {
    my ($self, $next_phase) = @_;
    $self->release_protocol();
    my $protocol = 
        Ocean::StreamComponent::ProtocolFactory->get_protocol($next_phase);
    $protocol->set_delegate($self);
    $self->[PROTOCOL] = $protocol;

    if ( $next_phase eq Ocean::Constants::ProtocolPhase::AVAILABLE) {
        $self->[CLIENT_IO]->on_stream_upgraded_to_available();
    }
}

=head3 PROTOCOL -> SERVER

=cut

sub on_protocol_handle_bind_request {
    my ($self, $req) = @_;
    # XXX bad interface
    $req->resource( $self->bound_jid->resource );
    $self->[SERVER]->on_stream_handle_bind_request(
        $self->id, $self->user_id, $req);
}

sub on_protocol_handle_vcard_request {
    my ($self, $req) = @_;
    $self->[SERVER]->on_stream_handle_vcard_request(
        $self->bound_jid, $req);
}

sub on_protocol_handle_too_manay_auth_attempt {
    my $self = shift;
    $self->[SERVER]->on_stream_handle_too_many_auth_attempt(
        $self->host, $self->port);
}

sub on_protocol_handle_too_many_stanza {
    my $self = shift;

    if ($self->is_bound) {
        warnf('<Stream:JID:%s> @too_many_stanza', $self->bound_jid->node);
    } else {
        warnf('<Stream:FD:%s> @too_many_stanza', $self->id);
    }

    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_protocol_handle_sasl_auth {
    my ($self, $auth) = @_;
    $self->[SERVER]->on_stream_handle_sasl_auth($self->id, $auth);
}

sub on_protocol_handle_sasl_password {
    my ($self, $username) = @_;
    $self->[SERVER]->on_stream_handle_sasl_password($self->id, $username);
}

sub on_protocol_handle_sasl_success_notification {
    my ($self, $username) = @_;
    $self->[SERVER]->on_stream_handle_sasl_success_notification($self->id, $username);
}

sub on_protocol_handle_http_auth {
    my ($self, $cookie) = @_;
    $self->[SERVER]->on_stream_handle_http_auth($self->id, $cookie);
}

sub on_protocol_handle_message {
    my ($self, $message) = @_;
    $self->[SERVER]->on_stream_handle_message(
        $self->bound_jid, $message);
}

sub on_protocol_handle_initial_presence {
    my ($self, $presence) = @_;
    $self->[STATUS] = STATUS_AVAILABLE;
    $self->on_protocol_step(
        Ocean::Constants::ProtocolPhase::AVAILABLE);
    $self->[SERVER]->on_stream_handle_initial_presence(
        $self->bound_jid, $presence);
}

sub on_protocol_handle_presence {
    my ($self, $presence) = @_;
    $self->[SERVER]->on_stream_handle_presence(
        $self->bound_jid, $presence);
}

sub on_protocol_handle_roster_request {
    my ($self, $req) = @_;
    $self->[SERVER]->on_stream_handle_roster_request(
        $self->bound_jid, $req);
}

sub on_protocol_completed_http_handshake {
    my ($self, $params) = @_;
    $self->[CLIENT_IO]->on_protocol_completed_http_handshake($params);
}

sub on_protocol_handle_ping {
    my ($self, $ping) = @_;

    infof('<Stream:JID:%s> @ping', $self->bound_jid->node);

    $self->[CLIENT_IO]->on_protocol_delivered_ping(
        $ping->id, $self->bound_jid);
}

sub on_protocol_delivered_disco_info {
    my ($self, $iq_id, $info) = @_;

    $self->[CLIENT_IO]->on_protocol_delivered_disco_info(
        $self->bound_jid, $info);
}

sub on_protocol_delivered_disco_items {
    my ($self, $iq_id, $items) = @_;

    $self->[CLIENT_IO]->on_protocol_delivered_disco_items(
        $self->bound_jid, $items);
}

sub on_protocol_delivered_room_invitation {
    my ($self, $invitation) = @_;

    $self->[CLIENT_IO]->on_protocol_delivered_room_invitation(
        $self->bound_jid, $invitation);
}

sub on_protocol_delivered_room_invitation_decline {
    my ($self, $decline) = @_;

    $self->[CLIENT_IO]->on_protocol_delivered_room_invitation_decline(
        $self->bound_jid, $decline);
}

sub on_protocol_delivered_room_service_info {
    my ($self, $iq_id, $info) = @_;

    $self->[CLIENT_IO]->on_protocol_delivered_disco_info(
        $self->bound_jid, $info);
}

sub on_protocol_handle_room_message {
    my ($self, $message) = @_;
    $self->[SERVER]->on_stream_handle_room_message(
        $self->bound_jid, $message);
}

sub on_protocol_handle_room_info_request {
    my ($self, $req) = @_;
    $self->[SERVER]->on_stream_handle_room_info_request(
        $self->bound_jid, $req);
}

sub on_protocol_handle_room_list_request {
    my ($self, $req) = @_;
    $self->[SERVER]->on_stream_handle_room_list_request(
        $self->bound_jid, $req);
}

sub on_protocol_handle_room_members_list_request {
    my ($self, $req) = @_;
    $self->[SERVER]->on_stream_handle_room_members_list_request(
        $self->bound_jid, $req);
}

sub on_protocol_handle_room_invitation {
    my ($self, $invitation) = @_;
    $self->[SERVER]->on_stream_handle_room_invitation(
        $self->bound_jid, $invitation);
}

sub on_protocol_handle_room_invitation_decline {
    my ($self, $decline) = @_;
    $self->[SERVER]->on_stream_handle_room_invitation_decline(
        $self->bound_jid, $decline);
}

sub on_protocol_handle_room_presence {
    my ($self, $presence) = @_;
    $self->[SERVER]->on_stream_handle_room_presence(
        $self->bound_jid, $presence);
}

sub on_protocol_handle_leave_room_presence {
    my ($self, $presence) = @_;
    $self->[SERVER]->on_stream_handle_leave_room_presence(
        $self->bound_jid, $presence);
}

sub on_protocol_handle_jingle_info_request {
    my ($self, $req) = @_;
    $self->[SERVER]->on_stream_handle_jingle_info_request(
        $self->bound_jid, $req);
}

sub on_protocol_handle_iq_toward_user {
    my ($self, $req) = @_;
    $self->[SERVER]->on_stream_handle_iq_toward_user(
        $self->bound_jid, $req);
}

sub on_protocol_handle_iq_toward_room_member {
    my ($self, $req) = @_;
    $self->[SERVER]->on_stream_handle_iq_toward_room_member(
        $self->bound_jid, $req);
}

sub on_protocol_completed_http_auth {
    my ($self, $user_id, $username, $session_id, $params) = @_;

    $self->[USER_ID] = $user_id;

    my $domain = Ocean::Config->instance->get(server => q{domain});
    $self->[BOUND_JID] = Ocean::JID->build($username, $domain, $session_id);

    $self->[CLIENT_IO]->on_protocol_completed_http_auth($params);

    $self->[STATUS] = STATUS_AVAILABLE;
    $self->on_protocol_step(
        Ocean::Constants::ProtocolPhase::AVAILABLE);
}

sub on_protocol_completed_http_session_auth {
    my ($self, $user_id, $username, $session_id) = @_;

    $self->[USER_ID] = $user_id;

    my $domain = Ocean::Config->instance->get(server => q{domain});
    $self->[BOUND_JID] = Ocean::JID->build($username, $domain, $session_id);

    $self->[STATUS] = STATUS_AUTHENTICATED;

    $self->[SERVER]->on_stream_completed_http_session_auth(
        $self->id, $user_id, $username, $session_id);
}

=head3 PROTOCOL -> CLIENT_IO

=cut

sub on_protocol_open_stream {
    my ($self, $features) = @_;
    my $stream_id = Ocean::Util::String::gen_random(10);
    # XXX should be keeped?
    # $self->{_current_stream_id} = $stream_id;
    $self->[CLIENT_IO]->on_protocol_open_stream(
        $stream_id, Ocean::Config->instance->get(server => q{domain}), $features);
}

sub on_protocol_starttls {
    my $self = shift;
    $self->[CLIENT_IO]->on_protocol_starttls();
}

sub on_protocol_delivered_sasl_challenge {
    my ($self, $challenge) = @_;
    $self->[CLIENT_IO]->on_protocol_delivered_sasl_challenge($challenge);
}

sub on_protocol_completed_sasl_auth {
    my ($self, $user_id, $username, $session_id) = @_;

    $self->[USER_ID] = $user_id;

    # XXX should be bundle at Handler?
    my $domain = Ocean::Config->instance->get(server => q{domain});
    $self->[BOUND_JID] = Ocean::JID->build($username, $domain, $session_id);

    $self->[STATUS] = STATUS_AUTHENTICATED;

    $self->[CLIENT_IO]->on_protocol_completed_sasl_auth();
}

sub on_protocol_completed_http_session_management {
    my ($self, $user_id, $bound_jid, $params) = @_;

    $self->[BOUND_JID] = $bound_jid;

    $self->[CLIENT_IO]->on_protocol_completed_http_auth($params);

    $self->[STATUS] = STATUS_AVAILABLE;
    $self->on_protocol_step(
        Ocean::Constants::ProtocolPhase::AVAILABLE);
}

sub on_server_completed_http_session_management {
    my ($self, $user_id, $bound_jid) = @_;

    $self->[PROTOCOL]->on_server_completed_http_session_management($user_id, $bound_jid);
}

sub on_protocol_failed_sasl_auth {
    my ($self, $error_type) = @_;
    $self->[CLIENT_IO]->on_protocol_failed_sasl_auth($error_type);
}

sub on_protocol_failed_http_auth {
    my ($self, $error_type) = @_;
    $self->[CLIENT_IO]->on_protocol_failed_http_auth($error_type);
}

sub on_protocol_bound_jid {
    my ($self, $iq_id, $result) = @_;
    my $jid = $result->jid;
    #$self->[BOUND_JID] = $jid;
    $self->[STATUS] = STATUS_BOUND;
    $self->[CLIENT_IO]->on_protocol_bound_jid(
        $iq_id, Ocean::Config->instance->get(server => q{domain}), $result);
    $self->[SERVER]->on_stream_bound_jid(
        $self->id, $self->bound_jid);
}

sub on_protocol_started_session {
    my ($self, $iq_id) = @_;
    $self->[CLIENT_IO]->on_protocol_started_session(
        $iq_id, Ocean::Config->instance->get(server => q{domain}) );
}

sub on_protocol_delivered_message {
    my ($self, $message) = @_;
    $self->[CLIENT_IO]->on_protocol_delivered_message($message);
}

sub on_protocol_delivered_presence {
    my ($self, $presence) = @_;
    $self->[CLIENT_IO]->on_protocol_delivered_presence($presence);
}

sub on_protocol_delivered_unavailable_presence {
    my ($self, $sender_jid) = @_;
    $self->[CLIENT_IO]->on_protocol_delivered_unavailable_presence(
        $sender_jid,
        $self->bound_jid,
    );
}

sub on_protocol_delivered_pubsub_event {
    my ($self, $event) = @_;
    $self->[CLIENT_IO]->on_protocol_delivered_pubsub_event($event);
}

sub on_protocol_delivered_roster {
    my ($self, $iq_id, $roster) = @_;
    $self->[CLIENT_IO]->on_protocol_delivered_roster(
        $iq_id, 
        $self->bound_jid,
        $roster,
    );
}

sub on_protocol_delivered_roster_push {
    my ($self, $iq_id, $item) = @_;
    $self->[CLIENT_IO]->on_protocol_delivered_roster_push(
        $iq_id, 
        $self->bound_jid,
        $item,
    );
}

sub on_protocol_delivered_vcard {
    my ($self, $iq_id, $vcard) = @_;
    $self->[CLIENT_IO]->on_protocol_delivered_vcard(
        $iq_id, 
        $self->bound_jid,
        $vcard,
    );
}

sub on_protocol_delivered_iq_toward_user {
    my ($self, $iq_id, $query) = @_;
    $self->[CLIENT_IO]->on_protocol_delivered_iq_toward_user(
        $iq_id, 
        $self->bound_jid, 
        $query);
}

sub on_protocol_delivered_iq_toward_room_member {
    my ($self, $iq_id, $query) = @_;
    $self->[CLIENT_IO]->on_protocol_delivered_iq_toward_room_member(
        $iq_id,
        $self->bound_jid,
        $query);
}

sub on_protocol_delivered_room_message {
    my ($self, $message) = @_;
    $self->[CLIENT_IO]->on_protocol_delivered_room_message($message);
}


sub on_protocol_delivered_jingle_info {
    my ($self, $iq_id, $info) = @_;
    $self->[CLIENT_IO]->on_protocol_delivered_jingle_info(
        $iq_id, 
        $self->bound_jid, 
        $info);
}

sub on_protocol_delivered_message_error {
    my ($self, $error) = @_;
    $self->[CLIENT_IO]->on_protocol_delivered_message_error($error);
}

sub on_protocol_delivered_presence_error {
    my ($self, $error) = @_;
    $self->[CLIENT_IO]->on_protocol_delivered_presence_error($error);
}

sub on_protocol_delivered_iq_error {
    my ($self, $error) = @_;
    $self->[CLIENT_IO]->on_protocol_delivered_iq_error($error);
}

=head2 SERVER EVENTS

=head3 SERVER EVENTS

=cut

sub on_server_completed_sasl_auth {
    my ($self, $user_id, $username, $session_id) = @_;
    try {
        $self->[PROTOCOL]->on_server_completed_sasl_auth($user_id, $username, $session_id);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_completed_http_auth {
    my ($self, $user_id, $username, $session_id, $cookies) = @_;
    try {
        $self->[PROTOCOL]->on_server_completed_http_auth(
            $user_id, $username, $session_id, $cookies);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_failed_sasl_auth {
    my $self = shift;
    try {
        $self->[PROTOCOL]->on_server_failed_sasl_auth();
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_failed_http_auth {
    my $self = shift;
    try {
        $self->[PROTOCOL]->on_server_failed_http_auth();
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_bound_jid {
    my ($self, $result) = @_;
    try {
        $self->[PROTOCOL]->on_server_bound_jid($result);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_sasl_password {
    my ($self, $password) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_sasl_password($password);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_message {
    my ($self, $message) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_message($message);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_presence {
    my ($self, $presence) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_presence($presence);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_unavailable_presence {
    my ($self, $sender_jid) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_unavailable_presence(
            $sender_jid);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_pubsub_event {
    my ($self, $event) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_pubsub_event($event);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_roster {
    my ($self, $iq_id, $roster) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_roster(
            $iq_id, $roster);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_roster_push {
    my ($self, $iq_id, $item) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_roster_push(
            $iq_id, $item);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_vcard {
    my ($self, $iq_id, $vcard) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_vcard(
            $iq_id, $vcard);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_disco_info {
    my ($self, $iq_id, $info) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_disco_info(
            $iq_id, $info);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_disco_items {
    my ($self, $iq_id, $items) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_disco_items(
            $iq_id, $items);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_room_invitation {
    my ($self, $invitation) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_room_invitation(
            $invitation);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_room_invitation_decline {
    my ($self, $decline) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_room_invitation_decline(
            $decline);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_iq_toward_user {
    my ($self, $iq_id, $query) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_iq_toward_user(
            $iq_id, $query);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_iq_toward_room_member {
    my ($self, $iq_id, $query) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_iq_toward_room_member(
            $iq_id, $query);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_room_message {
    my ($self, $message) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_room_message($message);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_jingle_info {
    my ($self, $iq_id, $info) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_jingle_info(
            $iq_id, $info);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_message_error {
    my ($self, $error) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_message_error(
            $error);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_presence_error {
    my ($self, $error) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_presence_error(
            $error);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_iq_error {
    my ($self, $error) = @_;
    try {
        $self->[PROTOCOL]->on_server_delivered_presence_error(
            $error);
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            $self->_critf($_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub _critf {
    my ($self, $message) = @_;
    if ($self->bound_jid) {
        critf("<Stream:JID:%s> %s", $self->bound_jid->node, $message);
    } else {
        critf("<Stream:FD:%s> %s", $self->id, $message);
    }
}

=head2 DESTRUCTION

=cut

sub release_protocol {
    my $self = shift;
    if ($self->[PROTOCOL]) {
        # to avoid cyclic-reference
        $self->[PROTOCOL]->release();
        $self->[PROTOCOL] = undef;
    }
}

# call this before release parent object
# to avoid cyclic-reference
sub release {
    my $self = shift;
    if ($self->[SERVER]) {
        $self->[SERVER] = undef;
    }
    $self->release_protocol();
    if ($self->[CLIENT_IO]) {
        $self->[CLIENT_IO]->release();
        $self->[CLIENT_IO] = undef;
    }
}

1;
