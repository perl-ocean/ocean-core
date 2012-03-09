package Ocean::StreamComponent::Protocol::HTTPHandshake;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::Protocol';

use Ocean::Config;
use Ocean::Error;
use Ocean::Constants::ProtocolPhase;

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

    if (Ocean::Config->instance->has_section('sasl')) {

        $self->{_delegate}->on_protocol_completed_http_handshake($params);
        $self->{_delegate}->on_protocol_step(
            Ocean::Constants::ProtocolPhase::SASL_STREAM);

    } else {

        if (!$self->{_authenticated}) {
            $self->{_handshake_params} = $params;
            my $cookie = delete $params->{cookie} || '';
            $self->{_delegate}->on_protocol_handle_http_auth($cookie);
        } else {
            $self->{_delegate}->on_protocol_failed_http_auth();
        }

    }
}

sub on_server_completed_http_auth {

    my ($self, $user_id, $username, $session_id, $cookies) = @_;

    if (!$self->{_authenticated} && $self->{_handshake_params}) {

        my $params = $self->{_handshake_params} || +{};
        $params->{cookies} = $cookies;
        $self->{_authenticated} = 1;
        $self->{_delegate}->on_protocol_completed_http_auth(
            $user_id, $username, $session_id, $params);

    } else {

        $self->{_delegate}->on_protocol_failed_http_auth();

    }
}

sub on_server_failed_http_auth {
    my ($self) = @_;
    $self->{_delegate}->on_protocol_failed_http_auth();
}

1;
