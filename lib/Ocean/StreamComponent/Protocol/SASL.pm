package Ocean::StreamComponent::Protocol::SASL;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::Protocol';

use Ocean::Config;
use Ocean::Constants::StreamErrorType;
use Ocean::Constants::SASLErrorType;
use Ocean::Constants::ProtocolPhase;
use Ocean::Error;
use Ocean::XML::Namespaces qw(SESSION BIND);
use Ocean::StreamComponent::SASL::MechanismFactory;

use List::MoreUtils qw(none);
use Log::Minimal;

use constant DEFAULT_MAX_ATTEMPT => 10;

sub _initialize {
    my $self = shift;
    $self->{_attempt_counter}   = 0;
    $self->{_mechanism}         = undef;
}

sub on_client_received_sasl_auth {
    my ($self, $auth) = @_;

    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    ) if $self->{_mechanism};

    my $max_attempt = 
        Ocean::Config->instance->get('sasl' => 'max_attempt') || DEFAULT_MAX_ATTEMPT;
    # too many attempt
    if ($self->{_attempt_counter} > $max_attempt) {
        # notify operator
        $self->{_delegate}->on_protocol_handle_too_many_auth_attempt();
        # force to close stream
        Ocean::Error::ProtocolError->throw(
            type => Ocean::Constants::StreamErrorType::NOT_AUTHORIZED, 
        );
    }
        
    my $mechs = Ocean::Config->instance->get(sasl => q{mechanisms}) || [];
    if (none { $auth->mechanism eq $_ } @$mechs ) {
        return $self->{_delegate}->on_protocol_failed_sasl_auth(
            Ocean::Constants::SASLErrorType::INVALID_MECHANISM);
    }

    my $mechanism = 
        Ocean::StreamComponent::SASL::MechanismFactory->create_mechanism(
            $auth->mechanism);

    unless ($mechanism) {
        # TODO Internal Server Error
        return;
    }

    $self->{_mechanism} = $mechanism;
    $self->{_mechanism}->set_delegate($self);
    $self->{_mechanism}->start($auth);
}

sub on_client_received_sasl_challenge_response {
    my ($self, $res) = @_;

    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    ) unless $self->{_mechanism};

    $self->{_mechanism}->step($res);
}

sub on_mechanism_handle_sasl_auth {
    my ($self, $auth) = @_;
    $self->{_delegate}->on_protocol_handle_sasl_auth($auth);
}

sub on_mechanism_delivered_sasl_challenge {
    my ($self, $challenge) = @_;
    $self->{_delegate}->on_protocol_delivered_sasl_challenge($challenge);
}

sub on_mechanism_request_sasl_password {
    my ($self, $username) = @_;
    $self->{_delegate}->on_protocol_handle_sasl_password($username);
}

sub on_mechanism_completed_auth {
    my ($self, $username) = @_;
    $self->{_delegate}->on_protocol_handle_sasl_success_notification($username);
}

sub on_mechanism_failed_auth {
    my ($self, $error_type) = @_;

    $self->{_mechanism}->release();
    $self->{_mechanism} = undef;

    $self->{_attempt_counter}++;

    $self->{_delegate}->on_protocol_failed_sasl_auth($error_type);
}

sub on_server_delivered_sasl_password {
    my ($self, $password) = @_;

    Ocean::Error::ConditionMismatchedServerEvent->throw 
        unless $self->{_mechanism};

    $self->{_mechanism}->on_protocol_delivered_sasl_password($password);
}

sub on_server_completed_sasl_auth {
    my ($self, $user_id, $username, $session_id) = @_;

    Ocean::Error::ConditionMismatchedServerEvent->throw 
        unless $self->{_mechanism};

    $self->{_mechanism}->release();
    $self->{_mechanism} = undef;

    $self->{_delegate}->on_protocol_completed_sasl_auth($user_id, $username, $session_id);
    $self->{_delegate}->on_protocol_step(
        Ocean::Constants::ProtocolPhase::BIND_AND_SESSION_STREAM);
}

sub on_server_failed_sasl_auth {
    my $self = shift;

    Ocean::Error::ConditionMismatchedServerEvent->throw 
        unless $self->{_mechanism};

    $self->{_mechanism}->release();
    $self->{_mechanism} = undef;

    $self->{_attempt_counter}++;

    $self->{_delegate}->on_protocol_failed_sasl_auth(
        Ocean::Constants::SASLErrorType::NOT_AUTHORIZED);
}

sub release {
    my $self = shift;
    if ($self->{_mechanism}) {
        $self->{_mechanism}->release();
        $self->{_mechanism} = undef;
    }
    delete $self->{_delegate} 
        if $self->{_delegate};
}

1;
