package Ocean::StreamComponent::Protocol::BindAndSessionStream;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::Protocol::StreamBase';

use Ocean::Constants::ProtocolPhase;
use Ocean::XML::Namespaces qw(SESSION BIND);

sub get_features {
    my $self = shift;
    return [
        [ session => SESSION ],
        [ bind    => BIND    ],
    ];
}

sub get_next_phase {
    my $self = shift;
    return Ocean::Constants::ProtocolPhase::BIND_AND_SESSION;
}

1;
