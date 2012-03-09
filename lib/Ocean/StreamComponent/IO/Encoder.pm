package Ocean::StreamComponent::IO::Encoder;

use strict;
use warnings;

use Ocean::Error;

sub initialize {
    my $self = shift;
    # template method
}

sub on_write {
    my ($self, $callback) = @_;
    $self->{_on_write} = $callback;
}

sub send_http_handshake {
    my ($self, $handshake) = @_;
    # template method
}

sub send_http_handshake_error {
    my ($self, $code, $type) = @_;
    # template method
}

sub send_closing_http_handshake {
    my ($self) = @_;
    # template method
}

sub send_initial_stream {
    my ($self, $id, $domain) = @_;
    # template method
}

sub send_end_of_stream {
    my $self = shift;
    # template method
}

sub send_stream_error {
    my ($self, $type, $msg) = @_;
    # template method
}

sub send_stream_features {
    my ($self, $features) = @_;
    # template method
}

sub send_sasl_challenge {
    my ($self, $challenge) = @_;
    # template method
}

sub send_sasl_success {
    my ($self) = @_;
    # template method
}

sub send_sasl_failure {
    my ($self, $type) = @_;
    # template method
}

sub send_sasl_abort {
    my ($self, $type) = @_;
    # template method
}

sub send_tls_proceed {
    my ($self, $type) = @_;
    # template method
}

sub send_tls_failure {
    my ($self, $type) = @_;
    # template method
}

sub send_presence {
    my ($self, $presence) = @_;
    # template method
}

sub send_unavailable_presence {
    my ($self, $from, $to) = @_;
    # template method
}

sub send_message {
    my ($self, $message) = @_;
    # template method
}

sub send_room_invitation {
    my ($self, $invitation) = @_;
    # template method
}

sub send_room_invitation_decline {
    my ($self, $invitation) = @_;
    # template method
}

sub send_pubsub_event {
    my ($self, $event) = @_;
    # template method
}

sub send_message_error {
    my ($self, $error) = @_;
    # template method
}

sub send_presence_error {
    my ($self, $error) = @_;
    # template method
}

sub send_iq_error {
    my ($self, $error) = @_;
    # template method
}

sub send_bind_result {
    my ($self, $id, $domain, $result) = @_;
    # template method
}

sub send_session_result {
    my ($self, $id, $domain) = @_;
    # template method
}

sub send_roster_result {
    my ($self, $id, $domain, $to, $roster) = @_;
    # template method
}

sub send_roster_push {
    my ($self, $id, $domain, $to, $item) = @_;
    # template method
}

sub send_pong {
    my ($self, $id, $domain, $to) = @_;
    # template method
}

sub send_vcard {
    my ($self, $id, $to, $vcard) = @_;
    # template method
}

sub send_iq_toward_user {
    my ($self, $id, $to, $query) = @_;
    # template method
}

sub send_jingle_info {
    my ($self, $id, $to, $info) = @_;
    # template method
}

sub send_server_disco_info {
    my $self = shift;
    # template method
}

sub send_server_disco_items {
    my $self = shift;
    # template method
}

sub release {
    my $self = shift;
    # template method
}

1;
