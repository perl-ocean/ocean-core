package Ocean::StreamComponent::SASL::Mechanism::X_OAUTH2;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::SASL::Mechanism';
use Ocean::Error;
use Ocean::Constants::StreamErrorType;

use Log::Minimal;

sub start {
    my ($self, $auth) = @_;

    $self->{_delegate}->on_mechanism_handle_sasl_auth($auth);
}

sub step {
    my ($self, $input) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

sub on_protocol_delivered_sasl_password {
    my ($self, $password) = @_;
    Ocean::Error::ProtocolError->throw(
        type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
    );
}

1;
