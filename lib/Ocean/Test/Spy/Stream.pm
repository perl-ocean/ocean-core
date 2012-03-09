package Ocean::Test::Spy::Stream;

use strict;
use warnings;

sub new { 
    my ($class, %args) = @_;
    my $self = bless {
        _io_records     => [],
        _protocol_state => {},
    }, $class;
    return $self;
}

sub _record_io_event {
    my ($self, $type, $val) = @_;
    push(@{ $self->{_io_records} }, { type => $type, val => $val });
}

sub get_io_history {
    my ($self, $depth) = @_;
    return $self->{_io_records}[$depth];
}

sub get_protocol_state {
    my ($self, $key) = @_;
    return $self->{_protocol_state}{$key};
}

sub clear {
    my $self = shift;
    $self->{_io_records}     = [];
    $self->{_protocol_state} = {};
};

sub on_io_received_stream {
    my ($self, $attrs) = @_;
    $self->_record_io_event(q{stream}, { attrs => $attrs });
}

sub on_io_received_message {
    my ($self, $message) = @_;
    $self->_record_io_event(q{message}, { to_jid => $message->to, message => $message});
}

sub on_io_received_presence {
    my ($self, $presence) = @_;
    $self->_record_io_event(q{presence}, { presence => $presence });
}

sub on_io_received_unavailable_presence {
    my ($self) = @_;
    $self->_record_io_event(q{unavailable_presence}, {});
}

sub on_io_received_starttls {
    my ($self) = @_;
    $self->_record_io_event(q{starttls}, {});
}

sub on_io_negotiated_tls {
    my ($self) = @_;
    $self->_record_io_event(q{negotiated_tls}, {});
}

sub on_io_received_sasl_auth {
    my ($self, $auth) = @_;
    $self->_record_io_event(q{auth}, { auth => $auth });
}

sub on_io_received_bind_request {
    my ($self, $req) = @_;
    $self->_record_io_event(q{bind}, { req => $req });
}

sub on_io_received_session_request {
    my ($self, $req) = @_;
    $self->_record_io_event(q{session}, { req => $req });
}

sub on_io_received_roster_request {
    my ($self, $req) = @_;
    $self->_record_io_event(q{roster}, { req => $req });
}

sub on_io_received_vcard_request {
    my ($self, $req) = @_;
    $self->_record_io_event(q{vcard}, { req => $req });
}

sub on_io_received_ping {
    my ($self, $req) = @_;
    $self->_record_io_event(q{ping}, { req => $req });
}

sub on_io_received_disco_info_request {
    my ($self, $req) = @_;
    $self->_record_io_event(q{disco_info}, { req => $req });
}

sub on_io_received_disco_items_request {
    my ($self, $req) = @_;
    $self->_record_io_event(q{disco_items}, { req => $req });
}

sub on_io_closed {
    my $self = shift;
    $self->_record_io_event(q{closed}, {});
}

sub on_protocol_open_stream {
    my ($self, $features) = @_;
    $self->{_protocol_state}{features} = $features;
}

sub on_protocol_handle_message {
    my ($self, $message) = @_;
    $self->{_protocol_state}{message_to_jid} = $message->to;
    $self->{_protocol_state}{message} = $message;
}

sub on_protocol_handle_presence {
    my ($self, $presence) = @_;
    $self->{_protocol_state}{presence} = $presence;
}

sub on_protocol_handle_initial_presence {
    my ($self, $presence) = @_;
    $self->{_protocol_state}{initial_presence} = $presence;
}

sub on_protocol_handle_roster_request {
    my ($self, $req) = @_;
    $self->{_protocol_state}{roster} = $req;
}

sub on_protocol_handle_vcard_request {
    my ($self, $req) = @_;
    $self->{_protocol_state}{vcard} = $req;
}

sub on_protocol_handle_ping_request {
    my ($self, $req) = @_;
    $self->{_protocol_state}{ping} = $req;
}

sub on_protocol_starttls {
    my $self = shift;
    $self->{_protocol_state}{starttls} = 1;
}

sub on_protocol_started_session {
    my ($self, $iq_id) = @_;
    $self->{_protocol_state}{session_iq_id} = $iq_id;
}

sub on_protocol_handle_bind_request {
    my $self = shift;
    $self->{_protocol_state}{bind_request} = 1;
}

sub on_protocol_handle_sasl_auth {
    my ($self, $auth) = @_;
    $self->{_protocol_state}{handle_auth} = $auth;
}

sub on_protocol_failed_sasl_auth {
    my ($self, $error_type) = @_;
    $self->{_protocol_state}{failed_auth} = $error_type;
}

sub on_protocol_completed_sasl_auth {
    my ($self, $user_id) = @_;
    $self->{_protocol_state}{user_id} = $user_id;
}

sub on_protocol_bound_jid {
    my ($self, $iq_id, $bound_jid) = @_;
    $self->{_protocol_state}{bound_iq_id} = $iq_id;
    $self->{_protocol_state}{bound_jid} = $bound_jid;
}

sub on_protocol_handle_disco_info_request {
    my ($self, $req) = @_;
    $self->{_protocol_state}{disco_info} = $req;
}

sub on_protocol_handle_disco_items_request {
    my ($self, $req) = @_;
    $self->{_protocol_state}{disco_items} = $req;
}

sub on_protocol_step {
    my ($self, $next_phase) = @_;
    $self->{_protocol_state}{next_phase} = $next_phase;
}

sub on_protocol_delivered_message {
    my ($self, $message) = @_;
    $self->{_protocol_state}{server_message} = $message;
    $self->{_protocol_state}{server_message_sender_jid} = $message->from;
}

sub on_protocol_delivered_presence {
    my ($self, $presence) = @_;
    $self->{_protocol_state}{server_presence} = $presence;
    $self->{_protocol_state}{server_presence_sender_jid} = $presence->from; 
}

sub on_protocol_delivered_unavailable_presence {
    my ($self, $sender_jid) = @_;
    $self->{_protocol_state}{server_unavailable_presence_sender_jid} = $sender_jid; 
}

sub on_protocol_delivered_roster {
    my ($self, $iq_id, $roster) = @_;
    $self->{_protocol_state}{server_roster_iqid} = $iq_id;
    $self->{_protocol_state}{server_roster}      = $roster;
}

sub on_protocol_delivered_roster_push {
    my ($self, $iq_id, $item) = @_;
    $self->{_protocol_state}{server_roster_item_iqid} = $iq_id;
    $self->{_protocol_state}{server_roster_item} = $item;
}

sub on_protocol_delivered_vcard {
    my ($self, $iq_id, $vcard) = @_;
    $self->{_protocol_state}{server_vcard_iqid} = $iq_id;
    $self->{_protocol_state}{server_vcard} = $vcard;
}

1;
