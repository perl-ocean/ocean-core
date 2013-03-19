package Ocean::Server;

use strict;
use warnings;

use AnyEvent;
use Log::Minimal;
use Try::Tiny;

use Ocean::Config;
use Ocean::JID;
use Ocean::Constants::EventType;

use Ocean::HandlerArgs::NodeInitialization;
use Ocean::HandlerArgs::NodeTimerReport;
use Ocean::HandlerArgs::NodeExit;
use Ocean::HandlerArgs::BindRequest;
use Ocean::HandlerArgs::SilentDisconnection;
use Ocean::HandlerArgs::TooManyAuthAttempt;
use Ocean::HandlerArgs::HTTPAuthRequest;
use Ocean::HandlerArgs::SASLAuthRequest;
use Ocean::HandlerArgs::SASLPasswordRequest;
use Ocean::HandlerArgs::SASLSuccessNotification;
use Ocean::HandlerArgs::Message;
use Ocean::HandlerArgs::Presence;
use Ocean::HandlerArgs::InitialPresence;
use Ocean::HandlerArgs::UnavailablePresence;
use Ocean::HandlerArgs::RosterRequest;
use Ocean::HandlerArgs::vCardRequest;
use Ocean::HandlerArgs::RoomMessage;
use Ocean::HandlerArgs::RoomInfoRequest;
use Ocean::HandlerArgs::RoomListRequest;
use Ocean::HandlerArgs::RoomMembersListRequest;
use Ocean::HandlerArgs::RoomInvitation;
use Ocean::HandlerArgs::RoomInvitationDecline;
use Ocean::HandlerArgs::RoomPresence;
use Ocean::HandlerArgs::LeaveRoomPresence;
use Ocean::HandlerArgs::TowardUserIQ;
use Ocean::HandlerArgs::TowardRoomMemberIQ;
use Ocean::HandlerArgs::JingleInfoRequest;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _event_dispatcher => $args{event_dispatcher},
        _stream_manager   => $args{stream_manager}, 
        _stream_factory   => $args{stream_factory},
        _listener         => $args{listener},
        _daemonizer       => $args{daemonizer},
        _signal_handler   => $args{signal_handler},
        _timer            => $args{timer},
        _context          => $args{context},
    }, $class;
    return $self;
}

sub run {
    my $self = shift;
    $self->initialize();
    $self->start();
    $self->wait();
    $self->finalize();
}

sub initialize {
    my $self = shift;

    $self->{_stream_manager}->set_delegate($self);
    $self->{_context}->set_delegate($self);
    $self->{_timer}->set_delegate($self);
    $self->{_listener}->set_delegate($self);
    $self->{_signal_handler}->set_delegate($self);

    $self->{_context}->initialize();
    $self->{_daemonizer}->initialize();
}

sub start {
    my $self = shift;
    $self->{_exit_guard} = AE::cv;
    $self->{_exit_guard}->begin();
    $self->{_listener}->start();
    $self->{_timer}->start();
    $self->{_signal_handler}->setup();
}

sub wait {
    my $self = shift;
    $self->{_exit_guard}->recv();
}

sub finalize {
    my $self = shift;

    infof("<Server> completed to disconnect all streams");

    my $args = Ocean::HandlerArgs::NodeExit->new;
    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::NODE_EXIT, 
        $self->{_context},
        $args);

    $self->{_context}->finalize();
    $self->{_daemonizer}->finalize();
    infof("<Server> exit");
}

sub release {
    my $self = shift;
    if ($self->{_stream_manager}) {
        $self->{_stream_manager}->release();
        delete $self->{_stream_manager};
    }
    if ($self->{_context}) {
        $self->{_context}->release();
        delete $self->{_context};
    }
    if ($self->{_timer}) {
        $self->{_timer}->release();
        delete $self->{_timer};
    }
    if ($self->{_listener}) {
        $self->{_listener}->release();
        delete $self->{_listener};
    }
    if ($self->{_signal_handler}) {
        $self->{_signal_handler}->release();
        delete $self->{_signal_handler};
    }
}

sub DESTROY {
    my $self = shift;
    $self->release();
}

sub on_listener_accept {
    my ($self, $client_id, $client_socket) = @_;

    unless ($self->_verify_server_stats()) {
        $client_socket->shutdown();
        return;
    }
    $self->_establish_stream($client_id, $client_socket);
    $self->{_exit_guard}->begin();
}

sub on_listener_prepare {
    my ($self, $sock, $host, $port) = @_;

    $host ||= 'localhost';
    infof("<Server> started listening on %s:%d", $host, $port);

    my $args = Ocean::HandlerArgs::NodeInitialization->new({
        host => $host,
        port => $port,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::NODE_INIT, 
        $self->{_context}, $args, 1);
}

sub _establish_stream {
    my ($self, $client_id, $client_socket) = @_;

    my $stream = $self->{_stream_factory}->create_stream(
        $client_id, $client_socket);
    $self->{_stream_manager}->register_stream($stream);

    infof("<Server> has registered the connection");

    $self->_report_current_connection_count();
    $self->_report_total_connection_count();

}

sub _report_current_connection_count {
    my $self = shift;
    my $counter = $self->{_stream_manager}->get_current_connection_counter();
    if ($counter == 0) {
        infof("<Server> Now this server has no client connection");
    } elsif ($counter == 1) {
        infof("<Server> Now this server is connected to one single stream");
    } else {
        infof("<Server> Now this server is connected to %d streams", 
            $counter);
    }
}

sub _report_total_connection_count {
    my $self = shift;
    my $total_counter = 
        $self->{_stream_manager}->get_total_connection_counter();
    if ($total_counter == 1) {
        infof("<Server> This is 1st stream in total as of this server started.");
    } elsif ($total_counter == 2) {
        infof("<Server> This is 2nd stream in total as of this server started.");
    } elsif ($total_counter == 3) {
        infof("<Server> This is 3rd stream in total as of this server started.");
    } else {
        infof("<Server> This is %dth stream in total as of this server started.", 
            $total_counter);
    }
}

sub _verify_server_stats {
    my $self = shift;

    if ($self->{_stream_manager}->get_current_connection_counter() + 1 > 
        Ocean::Config->instance->get(server => 'max_connection') ) {

        # XXX should notify to operators?
        warnf("<Server> Connection not accepted - over capacity");
        return 0;

    }

    return 1;
}

sub on_signal_quit {
    my $self = shift;
    $self->shutdown();
}

sub on_signal_refresh {
    my $self = shift;
    $self->refresh();
}

sub on_timer {
    my $self = shift;

    my $total_counter   = $self->{_stream_manager}->get_total_connection_counter();
    my $current_counter = $self->{_stream_manager}->get_current_connection_counter();

    my $args = Ocean::HandlerArgs::NodeTimerReport->new({
        total_connection_counter   => $total_counter,
        current_connection_counter => $current_counter,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::NODE_TIMER_REPORT, 
        $self->{_context}, $args);
}

sub shutdown {
    my $self = shift;

    infof("<Server> started shutdown...");
    $self->{_listener}->stop();
    infof("<Server> stopped listening");

    infof("<Server> started to disconnect all streams");
    $self->{_stream_manager}->disconnect_all();
    $self->{_exit_guard}->end();
}

sub refresh {
    my $self = shift;

    infof("<Server> started config refresh...");

    # event_dispatcher
    $self->{_event_dispatcher} = undef;
    $self->{_event_dispatcher} = Ocean::ServerComponentFactory->new->create_event_dispatcher;
    infof("<Server> rebuilt event dispatcher");

    # listener
    $self->{_listener}->stop;
    $self->{_listener} = undef;
    $self->{_listener} = Ocean::ServerComponentFactory->new->create_listener;
    $self->{_listener}->set_delegate($self);
    $self->{_listener}->start;
    infof("<Server> rebuilt listener");

    # timer
    $self->{_timer}->stop;
    $self->{_timer} = undef;
    $self->{_timer} = Ocean::ServerComponentFactory->new->create_timer;
    $self->{_timer}->set_delegate($self);
    $self->{_timer}->start;
    infof("<Server> rebuilt timer");

    $self->{_context}->reinitialize;
    infof("<Server> reinitialized context");

    infof("<Server> refreshed!");
}

=head2 STREAM CALLBACKS

=cut

sub on_stream_disconnected {
    my $self = shift;
    $self->{_exit_guard}->end();
    infof("<Server> A stream disconnected.");
    $self->_report_current_connection_count();
}

sub on_stream_handle_too_many_auth_attempt {
    my ($self, $host, $port) = @_;

    infof('<Stream> @%s { host: %s, port: %d }',
        Ocean::Constants::EventType::TOO_MANY_AUTH_ATTEMPT, 
        $host, $port);

    my $args = Ocean::HandlerArgs::TooManyAuthAttempt->new({
        host => $host,     
        port => $port,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::TOO_MANY_AUTH_ATTEMPT, 
        $self->{_context}, $args);
}

sub on_stream_handle_sasl_auth {
    my ($self, $stream_id, $domain, $auth) = @_;

    infof('<Stream:FD:%s> @%s { mechanism: %s, domain: %s } ',
        $stream_id,
        Ocean::Constants::EventType::SASL_AUTH_REQUEST, 
        $auth->mechanism,
        $domain,
    );

    my $args = Ocean::HandlerArgs::SASLAuthRequest->new({
        stream_id => $stream_id,
        domain    => $domain,
        mechanism => $auth->mechanism,
        text      => $auth->text || '',
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::SASL_AUTH_REQUEST, 
        $self->{_context}, $args);
}

sub on_stream_handle_sasl_password {
    my ($self, $stream_id, $username) = @_;

    infof('<Stream:FD:%s> @%s { username: %s }',
        $stream_id,
        Ocean::Constants::EventType::SASL_PASSWORD_REQUEST, 
        $username);

    my $args = Ocean::HandlerArgs::SASLPasswordRequest->new({
        stream_id => $stream_id,
        username  => $username,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::SASL_PASSWORD_REQUEST, 
        $self->{_context}, $args);
}

sub on_stream_handle_sasl_success_notification {
    my ($self, $stream_id, $username) = @_;

    infof('<Stream:FD:%s> @%s { username: %s }',
        $stream_id,
        Ocean::Constants::EventType::SASL_SUCCESS_NOTIFICATION, 
        $username);

    my $args = Ocean::HandlerArgs::SASLSuccessNotification->new({
        stream_id => $stream_id,
        username  => $username,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::SASL_SUCCESS_NOTIFICATION, 
        $self->{_context}, $args);
}

sub on_stream_handle_http_auth {
    my ($self, $stream_id, $domain, $cookie, $origin, $query_params) = @_;

    infof('<Stream:FD:%s> @%s',
        $stream_id,
        Ocean::Constants::EventType::HTTP_AUTH_REQUEST);

    my $args = Ocean::HandlerArgs::HTTPAuthRequest->new({
        stream_id    => $stream_id,
        cookie       => $cookie || '',
        domain       => $domain,
        origin       => $origin,
        query_params => $query_params,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::HTTP_AUTH_REQUEST, 
        $self->{_context}, $args);
}

sub on_stream_handle_bind_request {
    my ($self, $stream_id, $user_id, $domain, $req) = @_;

    infof('<Stream:FD:%s> @%s { user_id: %s }', 
        $stream_id,
        Ocean::Constants::EventType::BIND_REQUEST, 
        $user_id);

    my $args = Ocean::HandlerArgs::BindRequest->new({
        stream_id   => $stream_id,
        user_id     => $user_id,
        domain      => $domain,
        resource    => $req->resource    || '',
        want_extval => $req->want_extval || 0,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::BIND_REQUEST, 
        $self->{_context}, $args);
}

sub on_stream_handle_message {
    my ($self, $sender_jid, $message) = @_;

    my $to_jid = $message->to;

    infof('<Stream:JID:%s> @%s { to: %s }', 
        $sender_jid->node,
        Ocean::Constants::EventType::SEND_MESSAGE, 
        $to_jid->node);

    my $args = Ocean::HandlerArgs::Message->new({
        from   => $sender_jid,     
        to     => $to_jid,
        body   => $message->body   // '',
        thread => $message->thread || '',
        state  => $message->state  || '',
        html   => $message->html   || '',
        # subject => $message->subject || '',
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::SEND_MESSAGE, 
        $self->{_context}, $args);
}

sub on_stream_handle_presence {
    my ($self, $sender_jid, $presence) = @_;

    infof('<Stream:JID:%s> @%s { show: %s }', 
        $sender_jid->node,
        Ocean::Constants::EventType::BROADCAST_PRESENCE, 
        $presence->show);

    my $args = Ocean::HandlerArgs::Presence->new({
        from   => $sender_jid,
        show   => $presence->show,
        status => $presence->status,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::BROADCAST_PRESENCE, 
        $self->{_context}, $args);
}

sub on_stream_handle_initial_presence {
    my ($self, $sender_jid, $presence, $no_probe) = @_;

    infof('<Stream:JID:%s> @%s', 
        $sender_jid->node,
        Ocean::Constants::EventType::BROADCAST_INITIAL_PRESENCE, 
    );

    my $args = Ocean::HandlerArgs::InitialPresence->new({
        from     => $sender_jid,
        no_probe => $no_probe || 0,
        show     => $presence->show,
        status   => $presence->status,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::BROADCAST_INITIAL_PRESENCE, 
        $self->{_context}, $args);
}

sub on_stream_handle_unavailable_presence {
    my ($self, $sender_jid) = @_;

    infof('<Stream:JID:%s> @%s', 
        $sender_jid->node,
        Ocean::Constants::EventType::BROADCAST_UNAVAILABLE_PRESENCE, 
    );

    my $args = Ocean::HandlerArgs::UnavailablePresence->new({
        from => $sender_jid,     
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::BROADCAST_UNAVAILABLE_PRESENCE, 
        $self->{_context}, $args);
}

sub on_stream_handle_silent_disconnection {
    my ($self, $sender_jid) = @_;

    infof('<Stream:JID:%s> @%s', 
        $sender_jid->node,
        Ocean::Constants::EventType::SILENT_DISCONNECTION, 
    );

    my $args = Ocean::HandlerArgs::SilentDisconnection->new({
        from => $sender_jid,     
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::SILENT_DISCONNECTION, 
        $self->{_context}, $args);
}

sub on_stream_handle_roster_request {
    my ($self, $sender_jid, $req) = @_;

    infof('<Stream:JID:%s> @%s',
        $sender_jid->node,
        Ocean::Constants::EventType::ROSTER_REQUEST, 
    );

    my $args = Ocean::HandlerArgs::RosterRequest->new({
        from           => $sender_jid,      
        id             => $req->id,
        want_photo_url => $req->want_photo_url,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::ROSTER_REQUEST, 
        $self->{_context}, $args);
}

sub on_stream_handle_vcard_request {
    my ($self, $sender_jid, $req) = @_;

    infof('<Stream:JID:%s> @%s { owner: %s }', 
        $sender_jid->node,
        Ocean::Constants::EventType::VCARD_REQUEST, 
        $req->to->node);

    my $args = Ocean::HandlerArgs::vCardRequest->new({
        from           => $sender_jid,     
        to             => $req->to,
        id             => $req->id,
        want_photo_url => $req->want_photo_url,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::VCARD_REQUEST, 
        $self->{_context}, $args);
}

sub on_stream_handle_room_message {
    my ($self, $sender_jid, $message) = @_;

    infof('<Stream:JID:%s> @%s { room: %s }', 
        $sender_jid->node,
        Ocean::Constants::EventType::SEND_ROOM_MESSAGE, 
        $message->room,
    );

    my $args = Ocean::HandlerArgs::RoomMessage->new({
        from     => $sender_jid,
        room     => $message->room,
        body     => $message->body,
        html     => $message->html,
        subject  => $message->subject,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::SEND_ROOM_MESSAGE, 
        $self->{_context}, $args);
}

sub on_stream_handle_room_info_request {
    my ($self, $sender_jid, $req) = @_;

    infof('<Stream:JID:%s> @%s', 
        $sender_jid->node,
        Ocean::Constants::EventType::ROOM_INFO_REQUEST, 
    );

    my $args = Ocean::HandlerArgs::RoomInfoRequest->new({
        from => $sender_jid,
        id   => $req->id,
        room => $req->room,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::ROOM_INFO_REQUEST, 
        $self->{_context}, $args);
}

sub on_stream_handle_room_list_request {
    my ($self, $sender_jid, $req) = @_;

    infof('<Stream:JID:%s> @%s', 
        $sender_jid->node,
        Ocean::Constants::EventType::ROOM_LIST_REQUEST, 
    );

    my $args = Ocean::HandlerArgs::RoomListRequest->new({
        from      => $sender_jid,
        id        => $req->id,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::ROOM_LIST_REQUEST, 
        $self->{_context}, $args);
}

sub on_stream_handle_room_members_list_request {
    my ($self, $sender_jid, $req) = @_;

    infof('<Stream:JID:%s> @%s { room: %s }', 
        $sender_jid->node,
        Ocean::Constants::EventType::ROOM_MEMBERS_LIST_REQUEST, 
        $req->room,
    );

    my $args = Ocean::HandlerArgs::RoomMembersListRequest->new({
        from => $sender_jid,
        id   => $req->id,
        room => $req->room,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::ROOM_MEMBERS_LIST_REQUEST, 
        $self->{_context}, $args);
}

sub on_stream_handle_room_invitation {
    my ($self, $sender_jid, $invitation) = @_;

    infof('<Stream:JID:%s> @%s { room: %s }', 
        $sender_jid->node,
        Ocean::Constants::EventType::ROOM_INVITATION, 
        $invitation->room,
    );

    my $args = Ocean::HandlerArgs::RoomInvitation->new({
        from   => $sender_jid,
        to     => $invitation->to,
        room   => $invitation->room,
        reason => $invitation->reason,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::ROOM_INVITATION, 
        $self->{_context}, $args);
}

sub on_stream_handle_room_invitation_decline {
    my ($self, $sender_jid, $invitation) = @_;

    infof('<Stream:JID:%s> @%s', 
        $sender_jid->node,
        Ocean::Constants::EventType::ROOM_INVITATION_DECLINE, 
    );

    my $args = Ocean::HandlerArgs::RoomInvitationDecline->new({
        from   => $sender_jid,
        to     => $invitation->to,
        room   => $invitation->room,
        reason => $invitation->reason,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::ROOM_INVITATION_DECLINE, 
        $self->{_context}, $args);
}

sub on_stream_handle_room_presence {
    my ($self, $sender_jid, $presence) = @_;

    infof('<Stream:JID:%s> @%s { room: %s }', 
        $sender_jid->node,
        Ocean::Constants::EventType::ROOM_PRESENCE, 
        $presence->room,
    );

    my $args = Ocean::HandlerArgs::RoomPresence->new({
        from     => $sender_jid,
        room     => $presence->room,
        nickname => $presence->nickname,
        show     => $presence->show,
        status   => $presence->status,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::ROOM_PRESENCE, 
        $self->{_context}, $args);
}

sub on_stream_handle_leave_room_presence {
    my ($self, $sender_jid, $presence) = @_;

    infof('<Stream:JID:%s> @%s { room: %s }', 
        $sender_jid->node,
        Ocean::Constants::EventType::LEAVE_ROOM_PRESENCE, 
        $presence->room,
    );

    my $args = Ocean::HandlerArgs::LeaveRoomPresence->new({
        from     => $sender_jid,
        room     => $presence->room,
        nickname => $presence->nickname,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::LEAVE_ROOM_PRESENCE, 
        $self->{_context}, $args);
}

sub on_stream_handle_jingle_info_request {
    my ($self, $sender_jid, $req) = @_;

    infof('<Stream:JID:%s> @%s { to: %s }', 
        $sender_jid->node,
        Ocean::Constants::EventType::JINGLE_INFO_REQUEST, 
        $req->to->node);

    my $args = Ocean::HandlerArgs::JingleInfoRequest->new({
        from => $sender_jid, 
        id   => $req->id,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::JINGLE_INFO_REQUEST, 
        $self->{_context}, $args);
}

sub on_stream_handle_iq_toward_user {
    my ($self, $sender_jid, $req) = @_;

    infof('<Stream:JID:%s> @%s { to: %s }', 
        $sender_jid->node,
        Ocean::Constants::EventType::SEND_IQ_TOWARD_USER, 
        $req->to->node);

    my $args = Ocean::HandlerArgs::TowardUserIQ->new({
        from => $sender_jid, 
        id   => $req->id,
        type => $req->type,
        to   => $req->to,
        raw  => $req->raw,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::SEND_IQ_TOWARD_USER, 
        $self->{_context}, $args);
}

sub on_stream_handle_iq_toward_room_member {
    my ($self, $sender_jid, $req) = @_;

    infof('<Stream:JID:%s> @%s { room: %s, nickname: %s }', 
        $sender_jid->node,
        Ocean::Constants::EventType::SEND_IQ_TOWARD_ROOM_MEMBER, 
        $req->room,
        $req->nickname);

    my $args = Ocean::HandlerArgs::TowardRoomMemberIQ->new({
        from     => $sender_jid, 
        id       => $req->id,
        type     => $req->type,
        room     => $req->room,
        nickname => $req->nickname,
        raw      => $req->raw,
    });

    $self->{_event_dispatcher}->dispatch(
        Ocean::Constants::EventType::SEND_IQ_TOWARD_ROOM_MEMBER, 
        $self->{_context}, $args);
}

sub deliver_sasl_auth_completion {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_completed_sasl_auth(
        $result->stream_id, $result->user_id, 
        $result->username, $result->session_id);
}

sub deliver_http_auth_completion {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_completed_http_auth(
        $result->stream_id, $result->user_id, 
        $result->username, $result->session_id, $result->cookies, $result->headers);
}

sub deliver_sasl_password {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_delivered_sasl_password(
        $result->stream_id, $result->password);
}

sub deliver_sasl_auth_failure {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_failed_sasl_auth($result->stream_id);
}

sub deliver_http_auth_failure {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_failed_http_auth($result->stream_id);
}

sub deliver_bound_jid {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_bound_jid(
        $result->stream_id, $result);
}

sub deliver_message {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_delivered_message($result);
}

sub deliver_presence {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_delivered_presence($result);
}

sub deliver_unavailable_presence {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_delivered_unavailable_presence(
        $result->from, $result->to);
}

sub deliver_roster {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_delivered_roster(
        $result->to, $result->request_id, $result);
}

sub deliver_roster_push {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_delivered_roster_push(
        $result->to, $result->request_id, $result->item);
}

sub deliver_vcard {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_delivered_vcard(
        $result->to, $result->request_id, $result);
}

sub deliver_disco_info {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_delivered_disco_info(
        $result->to, $result->id, $result);
}

sub deliver_disco_items {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_delivered_disco_items(
        $result->to, $result->id, $result);
}

sub deliver_room_invitation {
    my ($self, $invitation) = @_;
    $self->{_stream_manager}->on_server_delivered_room_invitation(
        $invitation->to, $invitation);
}

sub deliver_room_invitation_decline {
    my ($self, $decline) = @_;
    $self->{_stream_manager}->on_server_delivered_room_invitation_decline(
        $decline->to, $decline);
}

sub deliver_iq_toward_user {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_delivered_iq_toward_user(
        $result->to, $result->request_id, $result);
}

sub deliver_iq_toward_room_member {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_delivered_iq_toward_room_member(
        $result->to, $result->request_id, $result);
}

sub deliver_room_message {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_delivered_room_message($result);
}

sub deliver_jingle_info {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_delivered_jingle_info(
        $result->to, $result->id, $result);
}

sub deliver_pubsub_event {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_delivered_pubsub_event($result);
}

sub deliver_message_error {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_delivered_message_error($result);
}

sub deliver_presence_error {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_delivered_presence_error($result);
}

sub deliver_iq_error {
    my ($self, $result) = @_;
    $self->{_stream_manager}->on_server_delivered_iq_error($result);
}

sub on_handler_exception {
    my $self = shift;
    critf("<Server> Caught exception from handler, so start to shutdown.");
    $self->shutdown();
}

1;
