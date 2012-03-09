package Ocean::StreamComponent::Protocol::SASLStream;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::Protocol::StreamBase';

use Ocean::Constants::ProtocolPhase;
use Ocean::XML::Namespaces qw(SASL);
use Ocean::Config;

sub get_features {
    my $self = shift;
    my $mechs = Ocean::Config->instance->get(sasl => q{mechanisms});
    unless (ref $mechs && ref $mechs eq 'ARRAY') {
        $mechs = [$mechs];
    }
    my @mechanisms = map { ['mechanism', $_]  } @$mechs;
    return [ [
        mechanisms => SASL, [ @mechanisms ]
    ] ];
}

sub get_next_phase {
    my $self = shift;
    return Ocean::Constants::ProtocolPhase::SASL;
}

1;

