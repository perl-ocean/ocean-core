package Ocean::StreamComponent::Protocol::TLSStream;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::Protocol::StreamBase';

use Ocean::Constants::ProtocolPhase;
use Ocean::XML::Namespaces qw(TLS);

sub get_features {
    my $self = shift;
    return [ [ starttls => TLS ] ];
}

sub get_next_phase {
    my $self = shift;
    return Ocean::Constants::ProtocolPhase::TLS;
}

1;
