package Ocean::StreamComponent::Protocol::HTTPSessionHandshake;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::Protocol';

use Ocean::Error;
use Ocean::Constants::ProtocolPhase;

use Log::Minimal;

sub _initialize {
    my $self = shift;
    $self->{_authenticated}    = 0;
    $self->{_handshake_params} = undef;
}

sub on_client_negotiated_tls {
    my $self = shift;
    # do nothing
}

sub on_client_received_http_handshake {
    my ($self, $params) = @_;

    $self->{_delegate}->set_domain($params->{host} || '');

    if (!$self->{_authenticated}) {
        $self->{_handshake_params} = $params;
        my $cookie = delete $params->{cookie} || '';
        my $domain = delete $params->{host} || '';
        $self->{_delegate}->on_protocol_handle_http_auth($cookie, $domain);
    } else {
        $self->{_delegate}->on_protocol_failed_http_auth();
    }
}

sub on_server_completed_http_auth {
    my ($self, $user_id, $username, $session_id, $cookies) = @_;

    if (!$self->{_authenticated} && $self->{_handshake_params}) {
        my $params = $self->{_handshake_params} || +{};
        $params->{cookies} = $cookies;
        $self->{_authenticated} = 1;
        $self->{_delegate}->on_protocol_completed_http_session_auth(
            $user_id, $username, $session_id);
    } else {
        $self->{_delegate}->on_protocol_failed_http_auth();
    }
}

sub on_server_failed_http_auth {
    my ($self) = @_;
    $self->{_delegate}->on_protocol_failed_http_auth();
}

sub on_server_completed_http_session_management {
    my ($self, $user_id, $bound_jid) = @_;

    if ($self->{_authenticated} && $self->{_handshake_params}) {
        my $params  = delete $self->{_handshake_params};
        $self->{_delegate}->on_protocol_completed_http_session_management(
            $user_id, $bound_jid, $params);
    } else {
        $self->{_delegate}->on_protocol_failed_http_auth();
    }
}

1;
