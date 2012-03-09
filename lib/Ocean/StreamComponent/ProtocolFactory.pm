package Ocean::StreamComponent::ProtocolFactory;

use strict;
use warnings;

use Carp ();

use Ocean::Constants::ProtocolPhase;
use Ocean::StreamComponent::Protocol::HTTPHandshake;
use Ocean::StreamComponent::Protocol::HTTPSessionHandshake;
use Ocean::StreamComponent::Protocol::TLSStream;
use Ocean::StreamComponent::Protocol::TLS;
use Ocean::StreamComponent::Protocol::SASLStream;
use Ocean::StreamComponent::Protocol::SASL;
use Ocean::StreamComponent::Protocol::BindAndSessionStream;
use Ocean::StreamComponent::Protocol::BindAndSession;
use Ocean::StreamComponent::Protocol::Active;
use Ocean::StreamComponent::Protocol::Available;

sub get_protocol {
    my ($class, $phase) = @_;

    if ($phase == Ocean::Constants::ProtocolPhase::HTTP_HANDSHAKE) {
        return Ocean::StreamComponent::Protocol::HTTPHandshake->new;
    }
    if ($phase == Ocean::Constants::ProtocolPhase::HTTP_SESSION_HANDSHAKE) {
        return Ocean::StreamComponent::Protocol::HTTPSessionHandshake->new;
    }
    elsif ($phase == Ocean::Constants::ProtocolPhase::TLS_STREAM) {
        return Ocean::StreamComponent::Protocol::TLSStream->new;
    }
    elsif ($phase == Ocean::Constants::ProtocolPhase::TLS) {
        return Ocean::StreamComponent::Protocol::TLS->new;
    }
    elsif ($phase == Ocean::Constants::ProtocolPhase::SASL_STREAM) {
        return Ocean::StreamComponent::Protocol::SASLStream->new;
    }
    elsif ($phase == Ocean::Constants::ProtocolPhase::SASL) {
        return Ocean::StreamComponent::Protocol::SASL->new;
    }
    elsif ($phase == Ocean::Constants::ProtocolPhase::BIND_AND_SESSION_STREAM) {
        return Ocean::StreamComponent::Protocol::BindAndSessionStream->new;
    }
    elsif ($phase == Ocean::Constants::ProtocolPhase::BIND_AND_SESSION) {
        return Ocean::StreamComponent::Protocol::BindAndSession->new;
    }
    elsif ($phase == Ocean::Constants::ProtocolPhase::ACTIVE) {
        return Ocean::StreamComponent::Protocol::Active->new;
    }
    elsif ($phase == Ocean::Constants::ProtocolPhase::AVAILABLE) {
        return Ocean::StreamComponent::Protocol::Available->new;
    }
    else {
        Carp::confess "must not come here";
    }
}

1;
