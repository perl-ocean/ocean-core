package Ocean::StreamManager;

use strict;
use warnings;

use Log::Minimal;

use Ocean::Error;
use Ocean::Stream;
use Ocean::Constants::StreamErrorType;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _server                     => undef,
        _unbound                    => {},
        _bound                      => {},
        _total_connection_counter   => 0,
        _current_connection_counter => 0,
        _bound_connection_counter   => 0,
        _unbound_connection_counter => 0,
    }, $class;
    return $self;
}

sub set_delegate {
    my ($self, $delegate) = @_;
    $self->{_server} = $delegate;
}

sub release {
    my $self = shift;
    delete $self->{_server};
}

sub register_stream {
    my ($self, $stream) = @_;
    $stream->set_delegate($self);
    $self->{_unbound}{$stream->id} = $stream;
    $self->{_current_connection_counter}++;
    $self->{_total_connection_counter}++;
    $self->{_unbound_connection_counter}++;
}

sub get_current_connection_counter {
    my $self = shift;
    return $self->{_current_connection_counter};
}

sub get_total_connection_counter {
    my $self = shift;
    return $self->{_total_connection_counter};
}

sub disconnect_all {
    my $self = shift;
    $self->disconnect_unbound();
    $self->disconnect_bound();
}

sub disconnect_bound {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::disconnect_bound}, 
    );
}

sub disconnect_unbound {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::disconnect_unbound}, 
    );
}

=head2 RETRIEVE STREAM

=cut

sub find_stream_by_id {
    my ($self, $stream_id) = @_;
    return $self->{_unbound}{$stream_id};
}

=head2 SESSION EVENTS

=cut

sub on_session_stream_closed {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_session_stream_closed}, 
    );
}

=head2 STREAM EVENTS


=cut

sub on_stream_completed_http_session_auth {
    my ($self, $stream_id, $user_id, $cookie) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_completed_http_auth}, 
    );
}

sub on_stream_bound_jid {
    my ($self, $stream_id, $bound_jid) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_bound_jid}, 
    );
}

sub on_stream_bound_closed {
    my ($self, $bound_jid) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_bound_closed}, 
    );
}

sub on_stream_unbound_closed {
    my ($self, $stream_id) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_unbound_closed}, 
    );
}

sub on_stream_handle_too_many_auth_attempt {
    my ($self, $host, $port) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_too_many_auth_attempt}, 
    );
}

sub on_stream_handle_sasl_auth {
    my ($self, $stream_id, $domain, $auth) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_sasl_auth}, 
    );
}

sub on_stream_handle_http_auth {
    my ($self, $stream_id, $cookie) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_http_auth}, 
    );
}

sub on_stream_handle_sasl_password {
    my ($self, $stream_id, $username) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_sasl_auth}, 
    );
}

sub on_stream_handle_sasl_success_notification {
    my ($self, $stream_id, $username) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_sasl_auth}, 
    );
}

sub on_stream_handle_bind_request {
    my ($self, $stream_id, $user_id, $domain, $req) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_bind_request}, 
    );
}

sub on_stream_handle_message {
    my ($self, $sender_id, $message) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_message}, 
    );
}

sub on_stream_handle_presence {
    my ($self, $sender_id, $presence) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_presence}, 
    );
}

sub on_stream_handle_initial_presence {
    my ($self, $sender_id, $presence, $no_probe) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_initial_presence}, 
    );
}

sub on_stream_handle_unavailable_presence {
    my ($self, $sender_id) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_unavailable_presence}, 
    );
}

sub on_stream_handle_silent_disconnection {
    my ($self, $sender_id) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_silent_disconnection}, 
    );
}

sub on_stream_handle_roster_request {
    my ($self, $sender_id, $req) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_roster_request}, 
    );
}

sub on_stream_handle_vcard_request {
    my ($self, $sender_id, $req) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_vcard_request}, 
    );
}

sub on_stream_handle_room_message {
    my ($self, $sender_id, $message) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_room_message}, 
    );
}

sub on_stream_handle_room_list_request {
    my ($self, $sender_id, $req) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_room_list_request}, 
    );
}

sub on_stream_handle_room_info_request {
    my ($self, $sender_id, $req) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_room_info_request}, 
    );
}

sub on_stream_handle_room_members_list_request {
    my ($self, $sender_id, $req) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_room_members_list_request}, 
    );
}

sub on_stream_handle_room_invitation {
    my ($self, $sender_id, $req) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_room_invitation}, 
    );
}

sub on_stream_handle_room_invitation_decline {
    my ($self, $sender_id, $req) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_room_invitation_decline}, 
    );
}

sub on_stream_handle_room_presence {
    my ($self, $sender_id, $req) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_room_presence}, 
    );
}

sub on_stream_handle_leave_room_presence {
    my ($self, $sender_id, $req) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_leave_room_presence}, 
    );
}

sub on_stream_handle_jingle_info_request {
    my ($self, $sender_id, $req) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_jingle_info_request}, 
    );
}

sub on_stream_handle_iq_toward_user {
    my ($self, $sender_id, $req) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_iq_toward_user}, 
    );
}

sub on_stream_handle_iq_toward_room_member {
    my ($self, $sender_id, $req) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_stream_handle_iq_toward_room_member}, 
    );
}

=head2 SERVER EVENTS

=cut

sub on_server_completed_sasl_auth {
    my ($self, $stream_id, $user_id, $username, $session_id) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_completed_sasl_auth}, 
    );
}

sub on_server_completed_http_auth {
    my ($self, $stream_id, $user_id, $cookie) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_completed_http_auth}, 
    );
}

sub on_server_failed_sasl_auth {
    my ($self, $stream_id) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_failed_sasl_auth}, 
    );
}

sub on_server_failed_http_auth {
    my ($self, $stream_id) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_failed_http_auth}, 
    );
}

sub on_server_bound_jid {
    my ($self, $stream_id, $result) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_bound_jid}, 
    );
}

sub on_server_delivered_sasl_password {
    my ($self, $stream_id, $password) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_delivered_sasl_password}, 
    );
}

sub on_server_delivered_message {
    my ($self, $message) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_delivered_message}, 
    );
}

sub on_server_delivered_presence {
    my ($self, $presence) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_delivered_presence}, 
    );
}

sub on_server_delivered_unavailable_presence {
    my ($self, $sender_jid, $receiver_jid) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_delivered_unavailable_presence}, 
    );
}

sub on_server_delivered_roster {
    my ($self, $receiver_jid, $iq_id, $roster) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_delivered_roster}, 
    );
}

sub on_server_delivered_roster_push {
    my ($self, $receiver_jid, $iq_id, $item) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_delivered_roster_push}, 
    );
}

sub on_server_delivered_vcard {
    my ($self, $receiver_jid, $iq_id, $vcard) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_delivered_vcard}, 
    );
}

sub on_server_delivered_disco_info {
    my ($self, $receiver_jid, $iq_id, $info) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_delivered_disco_info}, 
    );
}

sub on_server_delivered_disco_items {
    my ($self, $receiver_jid, $iq_id, $items) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_delivered_disco_items}, 
    );
}

sub on_server_delivered_room_invitation {
    my ($self, $receiver_jid, $invitation) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_delivered_room_invitation}, 
    );
}

sub on_server_delivered_room_invitation_decline {
    my ($self, $receiver_jid, $decline) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_delivered_room_invitation_decline}, 
    );
}

sub on_server_delivered_pubsub_event {
    my ($self, $event) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_delivered_pubsub_event}, 
    );
}

sub on_server_delivered_iq_toward_user {
    my ($self, $receiver_jid, $iq_id, $result) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_delivered_iq_toward_user}, 
    );
}

sub on_server_delivered_iq_toward_room_member {
    my ($self, $receiver_jid, $iq_id, $result) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_delivered_iq_toward_room_member},
    );
}

sub on_server_delivered_room_message {
    my ($self, $message) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_delivered_room_message}, 
    );
}

sub on_server_delivered_jingle_info {
    my ($self, $receiver_jid, $iq_id, $result) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_delivered_jingle_info}, 
    );
}

sub on_server_delivered_message_error {
    my ($self, $event) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamManager::on_server_delivered_message_error}, 
    );
}

sub on_server_delivered_presence_error {
    my ($self, $event) = @_;
    Ocean::Error::AbstractMethod->throw(
        presence => q{Ocean::StreamManager::on_server_delivered_presence_error}, 
    );
}

sub on_server_delivered_iq_error {
    my ($self, $event) = @_;
    Ocean::Error::AbstractMethod->throw(
        iq => q{Ocean::StreamManager::on_server_delivered_iq_error}, 
    );
}

1;
