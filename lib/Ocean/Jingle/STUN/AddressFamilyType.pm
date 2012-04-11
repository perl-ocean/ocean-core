package Ocean::Jingle::STUN::AddressFamilyType;

use strict;
use warnings;

use base 'Exporter';

our %EXPORT_TAGS = (all => [qw(
    IPV4
    IPV6
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

use constant IPV4 => q{IPv4};
use constant IPV6 => q{IPv6};

1;
