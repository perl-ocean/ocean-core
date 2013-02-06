package Ocean::HTTPBinding::Session;

use strict;
use warnings;

use Ocean::Config;
use Ocean::Stanza::Incoming::Presence;
use Ocean::Stanza::Incoming::BindResource;

use Try::Tiny;
use Log::Minimal;
use AnyEvent;

use constant DEFAULT_PENDING_TIMEOUT => 10;

use constant {
    ID               => 0,
    SERVER           => 1,
    BOUND_JID        => 2,
    USER_ID          => 3,
    IS_AVAILABLE     => 4,
    CONNECTION_STATE => 5,
    STREAMS          => 6,
    PENDING_TIMER    => 7,
    CLOSE_ON_DELIVER => 8,
};

use constant {
    CONNECTION_STATE_INIT      => 0,
    CONNECTION_STATE_PENDING   => 1,
    CONNECTION_STATE_AVAILABLE => 2,
    CONNECTION_STATE_CLOSED    => 3,
};

sub new {
    my ($class, %args) = @_;
    my $self = bless [
        $args{id},                    # Session ID 
        undef,                        # SERVER
        undef,                        # BOUND_JID
        $args{user_id},               # USER_ID
        0,                            # IS_AVAILABLE
        CONNECTION_STATE_INIT,        # CONNECTION_STATE
        {},                           # STREAMS
        undef,                        # PENDING_TIMER
        $args{close_on_deliver} || 0, # CLOSE_ON_DELIVER
    ], $class;
    return $self;
}

sub id {
    my $self = shift;
    return $self->[ID];
}

sub user_id {
    my $self = shift;
    return $self->[USER_ID];
}

sub set_delegate {
    my ($self, $server) = @_;
    $self->[SERVER] = $server;
}

sub bound_jid {
    my $self = shift;
    return $self->[BOUND_JID];
}

sub is_bound {
    my $self = shift;
    return $self->[BOUND_JID] ? 1 : 0;
}

sub is_available {
    my $self = shift;
    return $self->[IS_AVAILABLE];
}

sub close_with_ending_stream {
    my ($self, $error_type, $error_msg) = @_;
    $self->[CONNECTION_STATE] = CONNECTION_STATE_CLOSED;
    for my $stream (values %{ $self->[STREAMS] }) {
        $stream->close_with_ending_stream($error_type, $error_msg);
    }
}

sub register_stream {
    my ($self, $stream) = @_;

    debugf("<Session> register_stream");

    $self->_append_and_setup_stream($stream);

    if ($self->[CONNECTION_STATE] == CONNECTION_STATE_INIT) {
        debugf("<Session> register_stream INIT");
        $self->[CONNECTION_STATE] = CONNECTION_STATE_AVAILABLE;
        $self->_send_bind_request($stream);
    }
    elsif ($self->[CONNECTION_STATE] == CONNECTION_STATE_AVAILABLE) {
        debugf("<Session> register_stream AVAILABLE");
        if ($self->is_bound()) {
            $stream->on_server_completed_http_session_management(
                $self->user_id, $self->bound_jid());
        }
        # $self->[SERVER]->on_stream_probe_friends_presence($self->bound_jid, $stream->id);
    }
    elsif ($self->[CONNECTION_STATE] == CONNECTION_STATE_PENDING) {
        debugf("<Session> register_stream PENDING");
        if ($self->is_bound()) {
            $stream->on_server_completed_http_session_management(
                $self->user_id, $self->bound_jid());
        }
        $self->_recover_from_pending();
        # $self->[SERVER]->on_stream_probe_friends_presence($self->bound_jid, $sream->id);
    }
}

sub _recover_from_pending {
    my $self = shift;
    # reset timer
    debugf("<Session> canceld shutdown, now become available");
    $self->[PENDING_TIMER] = undef;
    # $self->dispatch_buffered_events();
    $self->[CONNECTION_STATE] = CONNECTION_STATE_AVAILABLE;
}

sub _send_bind_request {
    my ($self, $stream) = @_;
    # TODO edit id and resource
    my $req = Ocean::Stanza::Incoming::BindResource->new('id', $self->id);
    $self->[SERVER]->on_stream_handle_bind_request(
        $self->id, $self->user_id, $stream->domain, $req);
}

sub _send_initial_presence {
    my $self = shift;
    $self->[IS_AVAILABLE] = 1;
    my $presence = Ocean::Stanza::Incoming::Presence->new();
    # FIXME later: the way using probe( CLOSE_ON_DELIVER ) is not good
    $self->[SERVER]->on_stream_handle_initial_presence(
        $self->bound_jid, $presence, $self->[CLOSE_ON_DELIVER]);
}

sub _append_and_setup_stream {
    my ($self, $stream) = @_;
    $self->[STREAMS]{$stream->id} = $stream;
    $stream->set_delegate($self);
}

sub _has_stream {
    my $self = shift;
    return (scalar keys %{ $self->[STREAMS] } != 0);
}

sub _pending_timeout {
    my $self = shift;
    debugf('<Session> @Timeout');
    $self->[SERVER]->on_stream_handle_unavailable_presence($self->bound_jid);
    $self->[SERVER]->on_stream_bound_closed($self->bound_jid);
}

=head2 STREAM EVENTS

=cut

sub on_stream_completed_http_auth {
    my ($self, $stream_id, $user_id, $cookie) = @_;
    # not supported
    Ocean::Error::ProtocolError->throw;
}

sub on_stream_bound_jid {
    my ($self, $stream_id, $bound_jid) = @_;
    # not supported
    Ocean::Error::ProtocolError->throw;
}

sub on_stream_bound_closed {
    my ($self, $bound_jid, $stream_id) = @_;
    my $stream = delete $self->[STREAMS]{$stream_id};
    $stream->release();
    $self->[SERVER]->on_session_bound_stream_closed();
    $self->_start_pending_timer_if_needed();
}

sub on_stream_unbound_closed {
    my ($self, $stream_id) = @_;
    my $stream = delete $self->[STREAMS]{$stream_id};
    $stream->release();
    $self->[SERVER]->on_session_unbound_stream_closed();
    $self->_start_pending_timer_if_needed();
}

sub _start_pending_timer_if_needed {
    my $self = shift;
    if (   scalar keys %{ $self->[STREAMS] } == 0
        && $self->[CONNECTION_STATE] != CONNECTION_STATE_CLOSED) {
        # start timer
        my $timeout = 
            Ocean::Config->instance->get(http => q{pending_timeout}) 
            || DEFAULT_PENDING_TIMEOUT;
        $self->[PENDING_TIMER] = AE::timer $timeout, 0, sub {
            $self->_pending_timeout();  
        };
        $self->[CONNECTION_STATE] = CONNECTION_STATE_PENDING;
        debugf("<Stream> <Session> pending state");
    }
}

sub on_stream_handle_too_many_auth_attempt {
    my ($self, $host, $port) = @_;
    # not supported
    Ocean::Error::ProtocolError->throw;
}

sub on_stream_handle_sasl_auth {
    my ($self, $stream_id, $domain, $auth) = @_;
    # not supported
    Ocean::Error::ProtocolError->throw;
}

sub on_stream_handle_http_auth {
    my ($self, $stream_id, $domain, $cookie, $query_params) = @_;
    # not supported
    Ocean::Error::ProtocolError->throw;
}

sub on_stream_handle_bind_request {
    my ($self, $stream_id, $user_id, $req) = @_;
    # not supported
    Ocean::Error::ProtocolError->throw;
}

sub on_stream_handle_message {
    my ($self, $sender_id, $to_jid, $message) = @_;

    $self->[SERVER]->on_stream_handle_message(
        $sender_id, $to_jid, $message);

    # FIXME How to support message-sync among many streams.
    # - should support self-message-dispatch event?
    # - or let developer support message-sync with HTML5 WebStorage(sessionStorage)
}

sub on_stream_handle_presence {
    my ($self, $sender_id, $presence) = @_;

    $self->[SERVER]->on_stream_handle_presence(
        $sender_id, $presence);
}

sub on_stream_handle_initial_presence {
    my ($self, $sender_id, $presence) = @_;
    # not supported
    Ocean::Error::ProtocolError->throw;
}

sub on_stream_handle_unavailable_presence {
    my ($self, $sender_id) = @_;
    # Come here on client disconnection. Just Ignore
    # Handle disconnection on on_stream_bound_closed
}

sub on_stream_handle_silent_disconnection {
    my ($self, $sender_id) = @_;
    # not supported
    Ocean::Error::ProtocolError->throw;
}

sub on_stream_handle_roster_request {
    my ($self, $sender_id, $req) = @_;
    # not supported
    Ocean::Error::ProtocolError->throw;
}

sub on_stream_handle_vcard_request {
    my ($self, $sender_id, $req) = @_;
    # not supported
    Ocean::Error::ProtocolError->throw;
}

=head2 SERVER EVENTS

=head3 SERVER -> PROTOCOL

=cut

sub on_server_completed_sasl_auth {
    my ($self, $user_id) = @_;
    critf("<Session> on_server_completed_sasl_auth shouldn't be called");
}

sub on_server_completed_http_auth {
    my ($self, $user_id, $cookie) = @_;
    critf("<Session> on_server_completed_http_auth shouldn't be called");
}

sub on_server_failed_sasl_auth {
    my $self = shift;
    critf("<Session> on_server_failed_sasl_auth shouldn't be called");
}

sub on_server_failed_http_auth {
    my $self = shift;
    critf("<Session> on_server_failed_http_auth shouldn't be called");
}

sub on_server_bound_jid {
    my ($self, $result) = @_;

    debugf("<Session> on_server_bound_jid");

    try {

        unless ($self->is_bound) {

            my $jid = $result->jid;
            $self->[BOUND_JID] = $jid;

            for my $stream (values %{ $self->[STREAMS] }) {
                $stream->on_server_completed_http_session_management(
                    $self->user_id, $jid);
            }

            $self->_send_initial_presence();

        } else {
            critf("<Session> on_server_bound_jid mismatched condition");
        }

    } catch {

        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            critf("<Session> %s", $_->message);
        } else {
            # rethrow
            die $_;
        }

    };
}

sub on_server_delivered_message {
    my ($self, $message) = @_;
    try {
        if ($self->is_available) {
            if ($self->[CONNECTION_STATE] == CONNECTION_STATE_AVAILABLE) {
                for my $stream ( values %{ $self->[STREAMS] } ) {
                    $stream->on_server_delivered_message($message);
                    $stream->close() if $self->[CLOSE_ON_DELIVER];
                }
            }
            elsif ($self->[CONNECTION_STATE] == CONNECTION_STATE_PENDING) {
                # TODO
                # $self->save_event(message => $message);
            }
        } else {
            critf("<Session> on_server_delivered_message mismatched condition");
        }
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            critf("<Session> %s", $_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_presence {
    my ($self, $presence) = @_;
    try {
        if ($self->is_available) {
            if ($self->[CONNECTION_STATE] == CONNECTION_STATE_AVAILABLE) {
                for my $stream ( values %{ $self->[STREAMS] } ) {
                    $stream->on_server_delivered_presence($presence);
                    $stream->close() if $self->[CLOSE_ON_DELIVER];
                }
            }
            elsif ($self->[CONNECTION_STATE] == CONNECTION_STATE_PENDING) {
                # TODO
                # $self->save_event(presence => $presence);
            }
        } else {
            critf("<Session> on_server_delivered_presence mismatched condition");
        }
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            critf("<Session> %s", $_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_unavailable_presence {
    my ($self, $sender_jid) = @_;
    try {
        if ($self->is_available) {
            if ($self->[CONNECTION_STATE] == CONNECTION_STATE_AVAILABLE) {
                for my $stream ( values %{ $self->[STREAMS] } ) {
                    $stream->on_server_delivered_unavailable_presence($sender_jid);
                    $stream->close() if $self->[CLOSE_ON_DELIVER];
                }
            }
            elsif ($self->[CONNECTION_STATE] == CONNECTION_STATE_PENDING) {
                # TODO
                # $self->save_event(unavailable_presence => $sender_jid);
            }
        } else {
            critf("<Session> on_server_delivered_unavailable_presence mismatched condition");
        }
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            critf("<Session> %s", $_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}

sub on_server_delivered_pubsub_event {
    my ($self, $event) = @_;
    try {
        if ($self->is_available) {
            if ($self->[CONNECTION_STATE] == CONNECTION_STATE_AVAILABLE) {
                for my $stream ( values %{ $self->[STREAMS] } ) {
                    $stream->on_server_delivered_pubsub_event($event);
                    $stream->close() if $self->[CLOSE_ON_DELIVER];
                }
            }
            elsif ($self->[CONNECTION_STATE] == CONNECTION_STATE_PENDING) {
                # TODO
                # $self->save_event(event => $message);
            }
        } else {
            critf("<Session> on_server_delivered_pubsub_event mismatched condition");
        }
    } catch {
        if ($_->isa(q{Ocean::Error::ConditionMismatchedServerEvent})) {
            critf("<Session> %s", $_->message);
        } else {
            # rethrow
            die $_;
        }
    };
}


sub on_server_delivered_roster {
    my ($self, $iq_id, $roster) = @_;
    critf("<Session> on_server_delivered_roster shouldn't be called");
}

sub on_server_delivered_roster_push {
    my ($self, $iq_id, $item) = @_;
    critf("<Session> on_server_delivered_roster_push shouldn't be called");
}

sub on_server_delivered_vcard {
    my ($self, $iq_id, $vcard) = @_;
    critf("<Session> on_server_delivered_vcard shouldn't be called");
}

=head2 DESTRUCTION

=cut

sub release {
    my $self = shift;
    if ($self->[SERVER]) {
        $self->[SERVER] = undef;
    }
    for my $stream (values %{ $self->[STREAMS] }) {
        $stream->release();
    }
}

1;
