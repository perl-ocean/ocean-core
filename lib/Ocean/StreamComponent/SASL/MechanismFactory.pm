package Ocean::StreamComponent::SASL::MechanismFactory;

use strict;
use warnings;

use Ocean::StreamComponent::SASL::Mechanism::PLAIN;
use Ocean::StreamComponent::SASL::Mechanism::X_OAUTH2;
use Ocean::StreamComponent::SASL::Mechanism::CRAM_MD5;
use Ocean::StreamComponent::SASL::Mechanism::DIGEST_MD5;

my %MECHANISM_MAP = (
    'PLAIN'      => q{Ocean::StreamComponent::SASL::Mechanism::PLAIN}, 
    'X-OAUTH2'   => q{Ocean::StreamComponent::SASL::Mechanism::X_OAUTH2}, 
    'CRAM-MD5'   => q{Ocean::StreamComponent::SASL::Mechanism::CRAM_MD5}, 
    'DIGEST-MD5' => q{Ocean::StreamComponent::SASL::Mechanism::DIGEST_MD5}, 
);

sub create_mechanism {
    my ($class, $type) = @_;
    my $mech_class = $MECHANISM_MAP{$type} or return;
    return $mech_class->new;
}

1;
