package Ocean::StreamComponent::IO;

use strict;
use warnings;

use Encode;
use Try::Tiny;
use Log::Minimal;

use Ocean::Config;
use Ocean::Constants::StreamErrorType;
use Ocean::Stanza::DeliveryRequest::MessageError;
use Ocean::Stanza::DeliveryRequest::IQError;

use constant {
    STREAM     => 0,
    IS_CLOSING => 1,
    DECODER    => 2,
    ENCODER    => 3,
    SOCKET     => 4,
};

sub new {
    my ($class, %args) = @_;

    my $self = bless [
        undef, # STREAM
        0,     # IS_CLOSING
        undef, # DECODER
        undef, # ENCODER
        undef, # SOCKET
    ], $class;

    $self->[DECODER] = $self->_set_decoder_events($args{decoder});
    $self->[ENCODER] = $self->_set_encoder_events($args{encoder});
    $self->[SOCKET]  = $self->_set_socket_events($args{'socket'});

    return $self;
}

sub set_delegate {
    my ($self, $stream) = @_;
    $self->[STREAM] = $stream;
}

sub host { $_[0]->[SOCKET]->host }
sub port { $_[0]->[SOCKET]->port }

sub _handle_client_event_error {
    my ($self, $error) = @_;
    if (!(ref $error)) {
        critf(q{<Stream> Internal Server Error: "%s"}, $error);
        return $self->close_with_ending_stream(
            Ocean::Constants::StreamErrorType::INTERNAL_SERVER_ERROR);
    }
    elsif ($error->isa('Ocean::Error::HTTPHandshakeError')) {
        return $self->close_with_http_handshake_error(
            $error->code, $error->type);
    }
    elsif ($error->isa('Ocean::Error::ProtocolError')) {
        return $self->close_with_ending_stream(
            $error->type, $error->message);
    }
    elsif ($error->isa('Ocean::Error::MessageError')) {
        my $delivery_request = Ocean::Stanza::DeliveryRequest::MessageError->new({
            error_type   => $error->type, 
            error_reason => $error->condition,
            error_text   => $error->message,
            from         => Ocean::Config->instance->get(server => q{domain}),
        });
        $self->[ENCODER]->send_message_error($delivery_request);
    }
    elsif ($error->isa('Ocean::Error::IQError')) {
        my $delivery_request = Ocean::Stanza::DeliveryRequest::IQError->new({
            id           => $error->id,
            error_type   => $error->type, 
            error_reason => $error->condition,
            error_text   => $error->message,
            from         => Ocean::Config->instance->get(server => q{domain}),
        });
        $self->[ENCODER]->send_iq_error($delivery_request);
    }
    else {
        critf(q{<Stream> Internal Server Error: "%s"}, $error);
        return $self->close_with_ending_stream(
            Ocean::Constants::StreamErrorType::INTERNAL_SERVER_ERROR);
    }
}


# DECODER EVENTS
sub _set_decoder_events {
    my ($self, $decoder) = @_;
    $decoder->set_delegate($self);
    return $decoder;
}

sub on_received_stream {
    my ($self, $attrs) = @_;
    $self->[STREAM]->on_io_received_stream($attrs);
}

sub on_received_message { 
    my ($self, $message) = @_;
    $self->[STREAM]->on_io_received_message($message);
}

sub on_received_presence { 
    my $self = shift;
    $self->[STREAM]->on_io_received_presence(@_);
}

sub on_received_unavailable_presence { 
    my $self = shift;
    $self->[STREAM]->on_io_received_unavailable_presence(@_);
}

sub on_received_starttls { 
    my $self = shift;
    $self->[STREAM]->on_io_received_starttls(@_);
}

sub on_received_sasl_auth { 
    my $self = shift;
    $self->[STREAM]->on_io_received_sasl_auth(@_);
}

sub on_received_sasl_challenge_response { 
    my $self = shift;
    $self->[STREAM]->on_io_received_sasl_challenge_response(@_);
}

sub on_received_bind_request { 
    my $self = shift;
    $self->[STREAM]->on_io_received_bind_request(@_);
}

sub on_received_session_request {
    my $self = shift; 
    $self->[STREAM]->on_io_received_session_request(@_);
}

sub on_received_roster_request { 
    my $self = shift;
    $self->[STREAM]->on_io_received_roster_request(@_);
}

sub on_received_vcard_request {
    my $self = shift;
    $self->[STREAM]->on_io_received_vcard_request(@_);
}

sub on_received_ping {
    my ($self, $ping) = @_;

    $self->[STREAM]->on_io_received_ping($ping);
}

sub on_received_disco_info_request {
    my ($self, $req) = @_;
    $self->[STREAM]->on_io_received_disco_info_request($req);
}

sub on_received_disco_items_request {
    my ($self, $req) = @_;
    $self->[STREAM]->on_io_received_disco_items_request($req);
}

sub on_received_room_message {
    my ($self, $message) = @_;
    $self->[STREAM]->on_io_received_room_message($message);
}

sub on_received_room_info_request {
    my ($self, $req) = @_;
    $self->[STREAM]->on_io_received_room_info_request($req);
}

sub on_received_room_service_info_request {
    my ($self, $req) = @_;
    $self->[STREAM]->on_io_received_room_service_info_request($req);
}

sub on_received_room_list_request {
    my ($self, $req) = @_;
    $self->[STREAM]->on_io_received_room_list_request($req);
}

sub on_received_room_members_list_request {
    my ($self, $req) = @_;
    $self->[STREAM]->on_io_received_room_members_list_request($req);
}

sub on_received_room_invitation {
    my ($self, $invitation) = @_;
    $self->[STREAM]->on_io_received_room_invitation($invitation);
}

sub on_received_room_invitation_decline {
    my ($self, $decline) = @_;
    $self->[STREAM]->on_io_received_room_invitation_decline($decline);
}

sub on_received_room_presence {
    my ($self, $presence) = @_;
    $self->[STREAM]->on_io_received_room_presence($presence);
}

sub on_received_leave_room_presence {
    my ($self, $presence) = @_;
    $self->[STREAM]->on_io_received_leave_room_presence($presence);
}

sub on_received_jingle_info_request {
    my ($self, $req) = @_;
    $self->[STREAM]->on_io_received_jingle_info_request($req);
}

sub on_received_iq_toward_user {
    my ($self, $req) = @_;
    $self->[STREAM]->on_io_received_iq_toward_user($req);
}

sub on_received_iq_toward_room_member {
    my ($self, $req) = @_;
    $self->[STREAM]->on_io_received_iq_toward_room_member($req);
}

sub on_client_event_error {
    my ($self, $error) = @_;
    $self->_handle_client_event_error($error);
}

sub on_received_handshake {
    my ($self, $params) = @_;
    $self->[STREAM]->on_io_received_http_handshake($params);
}

sub on_received_closing_handshake {
    my ($self) = @_;
    $self->close();
}

# ENCODER EVENTS
sub _set_encoder_events {
    my ($self, $encoder) = @_;
    $encoder->on_write(sub { $self->_write_data(@_) });
    return $encoder;
}

sub _write_data {
    my ($self, $data) = @_;
    $self->[SOCKET]->push_write($data)
        if $self->[SOCKET]
}

sub _set_socket_events {
    my ($self, $socket) = @_;
    $socket->set_delegate($self);
    return $socket;
}

sub on_socket_read_data {
    my ($self, $data) = @_;
    if ($$data =~ /^[\r\n\s]+$/) {
        debugf('<Stream> <IO> @empty_packet ignore');
        return;
    }
    try {
        $self->[DECODER]->feed(substr($$data, 0, length($$data), ''))
            if $self->[DECODER] && !$self->[IS_CLOSING];
    } catch {
        $self->_handle_client_event_error($_);
    };
}

sub on_socket_negotiated_tls {
    my $self = shift;
    $self->[DECODER]->initialize();
    $self->[ENCODER]->initialize();
    $self->[STREAM]->on_io_negotiated_tls();
}

sub on_socket_timeout {
    my $self = shift;

    debugf('<Stream> @timeout');

    $self->close_with_ending_stream(
        Ocean::Constants::StreamErrorType::CONNECTION_TIMEOUT);
}

sub on_socket_closed {
    my $self = shift;
    $self->[STREAM]->on_io_closed();
}

# PROTOCOL DELEGATION INTERFACES
sub on_protocol_completed_http_handshake {
    my ($self, $params) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_http_handshake($params);
}

sub on_protocol_open_stream {
    my ($self, $id, $host, $features) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_initial_stream($id, $host);
    $self->[ENCODER]->send_stream_features($features||[]);
}

sub on_protocol_starttls {
    my $self = shift;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_tls_proceed();
    $self->[SOCKET]->accept_tls(Ocean::Config->instance->get('tls'));
}

sub on_protocol_started_session {
    my ($self, $iq_id, $host) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_session_result($iq_id, $host);
}

sub on_protocol_completed_sasl_auth {
    my $self = shift;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_sasl_success();
    $self->[DECODER]->initialize();
    $self->[ENCODER]->initialize();
}

sub on_protocol_completed_http_auth {
    my ($self, $params) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_http_handshake($params);
}

sub on_protocol_failed_sasl_auth {
    my ($self, $type) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_sasl_failure($type);
    # $self->close_with_ending_stream();
}

sub on_protocol_failed_http_auth {
    my ($self, $type) = @_;
    return if $self->[IS_CLOSING];
    $self->close_with_http_handshake_error(401, 'Unauthorized');
}

sub on_protocol_bound_jid {
    my ($self, $id, $host, $result) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_bind_result($id, $host, $result);
}

sub on_protocol_delivered_sasl_challenge {
    my ($self, $challenge) = @_;
    $self->[ENCODER]->send_sasl_challenge($challenge);
}

sub on_protocol_delivered_message {
    my ($self, $message) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_message($message);
}

sub on_protocol_delivered_presence {
    my ($self, $presence) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_presence($presence);
}

sub on_protocol_delivered_unavailable_presence {
    my ($self, $sender_jid, $receiver_jid) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_unavailable_presence(
        $sender_jid->as_string, 
        $receiver_jid->as_string, 
    );
}

sub on_protocol_delivered_pubsub_event {
    my ($self, $event) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_pubsub_event($event);
}

sub on_protocol_delivered_roster {
    my ($self, $iq_id, $receiver_jid, $roster) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_roster_result(
        $iq_id, 
        $receiver_jid->as_bare_string,
        $receiver_jid->as_string,
        $roster,
    );
}

sub on_protocol_delivered_roster_push {
    my ($self, $iq_id, $receiver_jid, $item) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_roster_push(
        $iq_id, 
        $receiver_jid->as_bare_string,
        $receiver_jid->as_string,
        $item,
    );
}

sub on_protocol_delivered_vcard {
    my ($self, $iq_id, $receiver_jid, $vcard) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_vcard(
        $iq_id, 
        $receiver_jid->as_string,
        $vcard,
    );
}

sub on_protocol_delivered_iq_toward_user {
    my ($self, $iq_id, $receiver_jid, $query) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_iq_toward_user(
        $iq_id, 
        $receiver_jid->as_string,
        $query,
    );
}

sub on_protocol_delivered_iq_toward_room_member {
    my ($self, $iq_id, $receiver_jid, $query) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_iq_toward_room_member(
        $iq_id,
        $receiver_jid->as_string,
        $query,
    );
}

sub on_protocol_delivered_room_message {
    my ($self, $message) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_message($message);
}

sub on_protocol_delivered_jingle_info {
    my ($self, $iq_id, $receiver_jid, $info) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_jingle_info(
        $iq_id, 
        $receiver_jid->as_string,
        $info,
    );
}

sub on_protocol_delivered_ping {
    my ($self, $iq_id, $receiver_jid) = @_;

    return if $self->[IS_CLOSING];

    $self->[ENCODER]->send_pong(
        $iq_id, 
        Ocean::Config->instance->get('server', 'domain'),
        $receiver_jid->as_string
    );
}

sub on_protocol_delivered_disco_info {
    my ($self, $receiver_jid, $info) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_server_disco_info(
        $info->id, 
        $info->from,
        $receiver_jid->as_string,
        $info
    );
}

sub on_protocol_delivered_disco_items {
    my ($self, $receiver_jid, $items) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_server_disco_items(
        $items->id, 
        $items->from,
        $receiver_jid->as_string,
        $items,
    );
}

sub on_protocol_delivered_room_invitation {
    my ($self, $receiver_jid, $invitation) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_room_invitation(
        $invitation,
    );
}

sub on_protocol_delivered_room_invitation_decline {
    my ($self, $receiver_jid, $decline) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_room_invitation_decline(
        $decline,
    );
}

sub on_protocol_delivered_message_error {
    my ($self, $error) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_message_error($error);
}

sub on_protocol_delivered_presence_error {
    my ($self, $error) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_presence_error($error);
}

sub on_protocol_delivered_iq_error {
    my ($self, $error) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_iq_error($error);
}

# CONNECTION STATE MANAGEMENT
sub on_stream_upgraded_to_available {
    my $self = shift;
    $self->[SOCKET]->on_stream_upgraded_to_available();
}

sub is_closing { $_[0]->[IS_CLOSING] }

sub close_with_http_handshake_error {
    my ($self, $code, $type) = @_;
    return if $self->[IS_CLOSING];
    $self->[ENCODER]->send_http_handshake_error($code, $type);
    $self->close();
}

sub close_with_ending_stream {
    my ($self, $error_type, $error_msg) = @_;
    return if $self->[IS_CLOSING];
    try {
        $self->[ENCODER]->send_stream_error($error_type, $error_msg);
        $self->[ENCODER]->send_end_of_stream();
        $self->close();
    } catch {
        critf("<Stream> caught exception while closing stream");
    };
}

sub close {
    my $self = shift;
    return if $self->[IS_CLOSING];
    $self->[IS_CLOSING] = 1;
    $self->[ENCODER]->send_closing_http_handshake();
    $self->[SOCKET]->close();
}

sub on_socket_eof {
    my $self = shift;
    return if $self->[IS_CLOSING];
    debugf('<Stream> <IO> start closing');
    $self->[IS_CLOSING] = 1;
    $self->[SOCKET]->close();
}

# call this before release parent object
# to avoid cyclic-reference
sub release {
    my $self = shift;
    if ($self->[STREAM]) {
        $self->[STREAM] = undef;
    }
    if ($self->[ENCODER]) {
        $self->[ENCODER]->release(); 
        $self->[ENCODER] = undef;
    }
    if ($self->[DECODER]) {
        $self->[DECODER]->release(); 
        $self->[DECODER] = undef;
    }
    if ($self->[SOCKET]) {
        $self->[SOCKET]->release(); 
        $self->[SOCKET] = undef;
    }
}

1;
