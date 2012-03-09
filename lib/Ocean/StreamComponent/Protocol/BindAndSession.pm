package Ocean::StreamComponent::Protocol::BindAndSession;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::Protocol';

use Ocean::Constants::StreamErrorType;
use Ocean::Constants::ProtocolPhase;
use Ocean::Error;

sub _initialize {
    my $self = shift;
    $self->{_is_bound}   = 0;
    $self->{_is_binding} = 0;
    $self->{_on_session} = 0;
}

sub on_client_received_bind_request {
    my ($self, $req) = @_;

    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    ) if ($self->{_is_bound} || $self->{_is_binding});

    $self->{_is_binding} = { id => $req->id };

    $self->{_delegate}->on_protocol_handle_bind_request($req);
}

sub on_client_received_session_request {
    my ($self, $req) = @_;

    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    ) if $self->{_is_binding};

    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    ) if $self->{_on_session};

    $self->{_on_session} = 1;

    $self->{_delegate}->on_protocol_started_session($req->id);

    if ($self->{_is_bound}) {
        $self->{_delegate}->on_protocol_step(
            Ocean::Constants::ProtocolPhase::ACTIVE);
    }
}

sub on_server_bound_jid {
    my ($self, $result) = @_;

    Ocean::Error::ConditionMismatchedServerEvent->throw
        unless $self->{_is_binding};

    my $req = delete $self->{_is_binding};
    $self->{_is_bound} = 1;

    $self->{_delegate}->on_protocol_bound_jid(
        $req->{id}, $result);

    if ($self->{_on_session}) {
        $self->{_delegate}->on_protocol_step(
            Ocean::Constants::ProtocolPhase::ACTIVE);
    }
}

sub on_server_delivered_iq_error {
    my ($self, $error) = @_;
    $self->{_delegate}->on_protocol_delivered_iq_error($error);
}

1;
