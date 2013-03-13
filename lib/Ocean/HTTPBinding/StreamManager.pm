package Ocean::HTTPBinding::StreamManager;

use strict;
use warnings;

use parent 'Ocean::StreamManager';

use Log::Minimal;

use Ocean::Stream;
use Ocean::HTTPBinding::Session;
use Ocean::Constants::StreamErrorType;

sub new {
    my ($class, %args) = @_;
    my $self = $class->SUPER::new(%args);
    $self->{_close_on_deliver} = $args{close_on_deliver} || 0;
    return $self;
}

sub disconnect_bound {
    my $self = shift;
    for my $username (keys %{ $self->{_bound}}) {
        my $resources = $self->{_bound}{$username};
        for my $resource (keys %$resources) {
            my $stream = $resources->{$resource};
            $stream->close_with_ending_stream(
                Ocean::Constants::StreamErrorType::SYSTEM_SHUTDOWN);
        }
    }
}

sub disconnect_unbound {
    my $self = shift;
    for my $stream_id (keys %{ $self->{_unbound} }) {
        my $stream = $self->{_unbound}{$stream_id};
        if ($stream && !$stream->is_closing()) {
            $stream->close_with_ending_stream(
                Ocean::Constants::StreamErrorType::SYSTEM_SHUTDOWN);
        }
    }
}

=head2 RETRIEVE STREAM

=cut

sub find_all_streams_hash_by_bare_jid {
    my ($self, $jid) = @_;
    return $self->{_bound}{$jid->node}||{};
}

sub find_all_streams_by_bare_jid {
    my ($self, $jid) = @_;
    my $resources = $self->{_bound}{$jid->node}||{};
    return [values %$resources];
}

sub find_stream_by_full_jid {
    my ($self, $jid) = @_;
    my $streams = $self->find_all_streams_hash_by_bare_jid($jid);
    return $streams->{$jid->resource};
}

=head2 SESSION EVENTS

=cut

# XXX fix me later
sub on_session_bound_stream_closed {
    my $self = shift;

    $self->{_bound_connection_counter}--;
    $self->{_current_connection_counter}--;

    $self->{_server}->on_stream_disconnected();
}

sub on_session_unbound_stream_closed {
    my $self = shift;

    # XXX this name 'bound_connection_counter' is bad
    $self->{_bound_connection_counter}--;
    $self->{_current_connection_counter}--;

    $self->{_server}->on_stream_disconnected();
}

=head2 STREAM EVENTS

=cut

sub on_stream_completed_http_session_auth {
    my ($self, $stream_id, $user_id, $username, $session_id) = @_;

    debugf("<Server> on_stream_completed_http_session_auth");

    my $stream = delete $self->{_unbound}{$stream_id};
    $self->{_unbound_connection_counter}--;
    # rebound session
    unless (exists $self->{_bound}{$username}) {
        $self->{_bound}{$username} = {};
    }
    unless (exists $self->{_bound}{$username}{$session_id}) {

        infof('<Server> @NewSession  { username: %s, session_id: %s }', 
            $username, $session_id);

        $self->{_bound}{$username}{$session_id} = Ocean::HTTPBinding::Session->new(
            id               => $session_id,
            user_id          => $user_id,
            close_on_deliver => $self->{_close_on_deliver},
        );
        $self->{_bound}{$username}{$session_id}->set_delegate($self);
    }
    $self->{_bound}{$username}{$session_id}->register_stream($stream);
    $self->{_bound_connection_counter}++;
}

#sub on_stream_bound_jid {
#    my ($self, $stream_id, $bound_jid) = @_;
#    # doesn't come here
#    # implement on_stream_completed_http_auth instead
#}


sub on_stream_bound_closed {
    my ($self, $bound_jid) = @_;
    my $resources = $self->{_bound}{$bound_jid->node};
    my $session = delete $resources->{$bound_jid->resource};
    $session->release() if $session;
}

sub on_stream_unbound_closed {
    my ($self, $stream_id) = @_;
    my $stream = delete $self->{_unbound}{$stream_id};
    $stream->release() if $stream;

    $self->{_unbound_connection_counter}--;
    $self->{_current_connection_counter}--;

    $self->{_server}->on_stream_disconnected();
}

sub on_stream_handle_too_many_auth_attempt {
    my ($self, $host, $port) = @_;
    $self->{_server}->on_stream_handle_too_many_auth_attempt(
        $host, $port);
}

sub on_stream_handle_sasl_auth {
    my ($self, $stream_id, $domain, $auth) = @_;
    $self->{_server}->on_stream_handle_sasl_auth($stream_id, $domain, $auth);
}

sub on_stream_handle_http_auth {
    my ($self, $stream_id, $domain, $cookie, $origin, $query_params) = @_;
    $self->{_server}->on_stream_handle_http_auth($stream_id, $domain, $cookie, $origin, $query_params);
}

sub on_stream_handle_bind_request {
    my ($self, $stream_id, $user_id, $domain, $req) = @_;
    $self->{_server}->on_stream_handle_bind_request(
        $stream_id, $user_id, $domain, $req);
}

sub on_stream_handle_message {
    my ($self, $sender_id, $message) = @_;
    $self->{_server}->on_stream_handle_message(
        $sender_id, $message);
}

sub on_stream_handle_presence {
    my ($self, $sender_id, $presence) = @_;
    $self->{_server}->on_stream_handle_presence(
        $sender_id, $presence);
}

sub on_stream_handle_initial_presence {
    my ($self, $sender_id, $presence, $no_probe) = @_;
    $self->{_server}->on_stream_handle_initial_presence(
        $sender_id, $presence, $no_probe);
}

sub on_stream_handle_unavailable_presence {
    my ($self, $sender_id) = @_;
    $self->{_server}->on_stream_handle_unavailable_presence(
        $sender_id);
}

sub on_stream_handle_silent_disconnection {
    my ($self, $sender_id) = @_;
    $self->{_server}->on_stream_handle_silent_disconnection(
        $sender_id);
}

sub on_stream_handle_roster_request {
    my ($self, $sender_id, $req) = @_;
    $self->{_server}->on_stream_handle_roster_request(
        $sender_id, $req);
}

sub on_stream_handle_vcard_request {
    my ($self, $sender_id, $req) = @_;
    $self->{_server}->on_stream_handle_vcard_request(
        $sender_id, $req);
}

sub on_stream_handle_room_message {
    my ($self, $sender_id, $message) = @_;
    $self->{_server}->on_stream_handle_room_message(
        $sender_id, $message);
}

sub on_stream_handle_room_info_request {
    my ($self, $sender_id, $req) = @_;
    $self->{_server}->on_stream_handle_room_info_request(
        $sender_id, $req);
}

sub on_stream_handle_room_list_request {
    my ($self, $sender_id, $req) = @_;
    $self->{_server}->on_stream_handle_room_list_request(
        $sender_id, $req);
}

sub on_stream_handle_room_members_list_request {
    my ($self, $sender_id, $req) = @_;
    $self->{_server}->on_stream_handle_room_members_list_request(
        $sender_id, $req);
}

sub on_stream_handle_room_invitation {
    my ($self, $sender_id, $invitation) = @_;
    $self->{_server}->on_stream_handle_room_invitation(
        $sender_id, $invitation);
}

sub on_stream_handle_room_invitation_decline {
    my ($self, $sender_id, $decline) = @_;
    $self->{_server}->on_stream_handle_room_invitation_decline(
        $sender_id, $decline);
}

sub on_stream_handle_room_presence {
    my ($self, $sender_id, $presence) = @_;
    $self->{_server}->on_stream_handle_room_presence(
        $sender_id, $presence);
}

sub on_stream_handle_leave_room_presence {
    my ($self, $sender_id, $presence) = @_;
    $self->{_server}->on_stream_handle_leave_room_presence(
        $sender_id, $presence);
}

sub on_stream_handle_jingle_info_request {
    my ($self, $sender_id, $req) = @_;
    $self->{_server}->on_stream_handle_jingle_info_request(
        $sender_id, $req);
}

sub on_stream_handle_iq_toward_user {
    my ($self, $sender_id, $req) = @_;
    $self->{_server}->on_stream_handle_iq_toward_user(
        $sender_id, $req);
}

sub on_stream_handle_iq_toward_room_member {
    my ($self, $sender_id, $req) = @_;
    $self->{_server}->on_stream_handle_iq_toward_room_member(
        $sender_id, $req);
}

=head2 SERVER EVENTS

=cut

sub on_server_completed_sasl_auth {
    my ($self, $stream_id, $user_id, $username, $session_id) = @_;
    my $stream = $self->find_stream_by_id($stream_id);
    $stream->on_server_completed_sasl_auth($user_id, $username, $session_id)
        if $stream;
}

sub on_server_completed_http_auth {
    my ($self, $stream_id, $user_id, $username, $session_id, $cookies, $headers) = @_;
    my $stream = $self->find_stream_by_id($stream_id);
    $stream->on_server_completed_http_auth($user_id, $username, $session_id, $cookies, $headers)
        if $stream;
}

sub on_server_failed_sasl_auth {
    my ($self, $stream_id) = @_;
    my $stream = $self->find_stream_by_id($stream_id);
    $stream->on_server_failed_sasl_auth() if $stream;
}

sub on_server_failed_http_auth {
    my ($self, $stream_id) = @_;
    my $stream = $self->find_stream_by_id($stream_id);
    $stream->on_server_failed_http_auth() if $stream;
}

sub on_server_bound_jid {
    my ($self, $stream_id, $result) = @_;
    my $jid = $result->jid;
    debugf("<Server> on_server_bound_jid - %s", $jid->as_string);
    my $stream = $self->find_stream_by_full_jid($result->jid);
    $stream->on_server_bound_jid($result) if $stream;
}

sub on_server_delivered_message {
    my ($self, $message) = @_;
    if ($message->to->resource) {
        my $stream = $self->find_stream_by_full_jid($message->to);
        $stream->on_server_delivered_message($message) 
            if $stream;
    } else {
        my $streams = $self->find_all_streams_by_bare_jid($message->to);
        $_->on_server_delivered_message($message) 
            for @$streams;
    }
}

sub on_server_delivered_presence {
    my ($self, $presence) = @_;
    if ($presence->to->resource) {
        my $stream = $self->find_stream_by_full_jid($presence->to);
        $stream->on_server_delivered_presence($presence) 
            if $stream;
    } else {
        my $streams = $self->find_all_streams_by_bare_jid($presence->to);
        $_->on_server_delivered_presence($presence) 
            for @$streams;
    }
}

sub on_server_delivered_unavailable_presence {
    my ($self, $sender_jid, $receiver_jid) = @_;
    if ($receiver_jid->resource) {
        my $stream = $self->find_stream_by_full_jid($receiver_jid);
        $stream->on_server_delivered_unavailable_presence(
            $sender_jid) if $stream;
    } else {
        my $streams = $self->find_all_streams_by_bare_jid($receiver_jid);
        $_->on_server_delivered_unavailable_presence(
            $sender_jid) for @$streams;
    }
}

sub on_server_delivered_roster {
    my ($self, $receiver_jid, $iq_id, $roster) = @_;
    if ($receiver_jid->resource) {
        my $stream = $self->find_stream_by_full_jid($receiver_jid);
        $stream->on_server_delivered_roster($iq_id, $roster) if $stream;
    } else {
        warnf("<Server> JID-resource not found");
    }
}

sub on_server_delivered_roster_push {
    my ($self, $receiver_jid, $iq_id, $item) = @_;
    if ($receiver_jid->resource) {
        my $stream = $self->find_stream_by_full_jid($receiver_jid);
        $stream->on_server_delivered_roster_push($iq_id, $item) if $stream;
    } else {
        warnf("<Server> JID-resource not found");
    }
}

sub on_server_delivered_vcard {
    my ($self, $receiver_jid, $iq_id, $vcard) = @_;
    if ($receiver_jid->resource) {
        my $stream = $self->find_stream_by_full_jid($receiver_jid);
        $stream->on_server_delivered_vcard($iq_id, $vcard) if $stream;
    } else {
        warnf("<Server> JID-resource not found");
    }
}

sub on_server_delivered_disco_info {
    my ($self, $receiver_jid, $iq_id, $info) = @_;
    if ($receiver_jid->resource) {
        my $stream = $self->find_stream_by_full_jid($receiver_jid);
        $stream->on_server_delivered_disco_info($iq_id, $info) if $stream;
    } else {
        warnf("<Server> JID-resource not found");
    }
}

sub on_server_delivered_disco_items {
    my ($self, $receiver_jid, $iq_id, $items) = @_;
    if ($receiver_jid->resource) {
        my $stream = $self->find_stream_by_full_jid($receiver_jid);
        $stream->on_server_delivered_disco_items($iq_id, $items) if $stream;
    } else {
        warnf("<Server> JID-resource not found");
    }
}

sub on_server_delivered_room_invitation {
    my ($self, $receiver_jid, $invitation) = @_;
    if ($receiver_jid->resource) {
        my $stream = $self->find_stream_by_full_jid($receiver_jid);
        $stream->on_server_delivered_room_invitation($invitation) 
            if $stream;
    } else {
        my $streams = $self->find_all_streams_by_bare_jid($receiver_jid);
        $_->on_server_delivered_room_invitation($invitation) 
            for @$streams;
    }
}

sub on_server_delivered_room_invitation_decline {
    my ($self, $receiver_jid, $decline) = @_;
    if ($receiver_jid->resource) {
        my $stream = $self->find_stream_by_full_jid($receiver_jid);
        $stream->on_server_delivered_room_invitation_decline($decline) if $stream;
    } else {
        warnf("<Server> JID-resource not found");
    }
}

sub on_server_delivered_pubsub_event {
    my ($self, $event) = @_;
    if ($event->to->resource) {
        my $stream = $self->find_stream_by_full_jid($event->to);
        $stream->on_server_delivered_pubsub_event($event) 
            if $stream;
    } else {
        my $streams = $self->find_all_streams_by_bare_jid($event->to);
        $_->on_server_delivered_pubsub_event($event) 
            for @$streams;
    }
}

sub on_server_delivered_iq_toward_user {
    my ($self, $receiver_jid, $iq_id, $query) = @_;
    if ($receiver_jid->resource) {
        my $stream = $self->find_stream_by_full_jid($receiver_jid);
        $stream->on_server_delivered_iq_toward_user($iq_id, $query) if $stream;
    } else {
        warnf("<Server> JID-resource not found");
    }
}

sub on_server_delivered_iq_toward_room_member {
    my ($self, $receiver_jid, $iq_id, $query) = @_;
    if ($receiver_jid->resource) {
        my $stream = $self->find_stream_by_full_jid($receiver_jid);
        $stream->on_server_delivered_iq_toward_room_member($iq_id, $query) if $stream;
    } else {
        warnf("<Server> JID-resource not found");
    }
}

sub on_server_delivered_jingle_info {
    my ($self, $receiver_jid, $iq_id, $info) = @_;
    if ($receiver_jid->resource) {
        my $stream = $self->find_stream_by_full_jid($receiver_jid);
        $stream->on_server_delivered_jingle_info($iq_id, $info) if $stream;
    } else {
        warnf("<Server> JID-resource not found");
    }
}

sub on_server_delivered_message_error {
    my ($self, $error) = @_;
    my $receiver_jid = $error->to;
    if ($receiver_jid->resource) {
        my $stream = $self->find_stream_by_full_jid($receiver_jid);
        $stream->on_server_delivered_message_error($error) if $stream;
    } else {
        warnf("<Server> JID-resource not found");
    }
}

sub on_server_delivered_presence_error {
    my ($self, $error) = @_;
    my $receiver_jid = $error->to;
    if ($receiver_jid->resource) {
        my $stream = $self->find_stream_by_full_jid($receiver_jid);
        $stream->on_server_delivered_presence_error($error) if $stream;
    } else {
        warnf("<Server> JID-resource not found");
    }
}

sub on_server_delivered_iq_error {
    my ($self, $error) = @_;
    my $receiver_jid = $error->to;
    if ($receiver_jid->resource) {
        my $stream = $self->find_stream_by_full_jid($receiver_jid);
        $stream->on_server_delivered_iq_error($error) if $stream;
    } else {
        warnf("<Server> JID-resource not found");
    }
}

1;
