package Ocean::Jingle::STUN::AttributeType;

use strict;
use warnings;

use base 'Exporter';

our %EXPORT_TAGS = (all => [qw(
    MAPPED_ADDRESS
    USERNAME
    MESSAGE_INTEGRITY
    ERROR_CODE
    UNKNOWN_ATTRIBUTES
    REALM
    NONCE
    XOR_MAPPED_ADDRESS
    SOFTWARE
    ALTERNATE_SERVER
    FINGERPRINT
    CHANNEL_NUMBER
    LIFETIME
    XOR_PEER_ADDRESS
    DATA
    XOR_RELAYED_ADDRESS
    EVEN_PORT
    REQUESTED_TRANSPORT
    DONT_FRAGMENT
    RESERVATION_TOKEN
    PRIORITY
    USE_CANDIDATE
    ICE_CONTROLLED
    ICE_CONTROLLING
    CHANGE_REQUEST
    RESPONSE_PORT
    PADDING
    CACHE_TIMEOUT
    RESPONSE_ORIGIN
    OTHER_ADDRESS
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

=head2 RFC5389 STUN

=cut

use constant MAPPED_ADDRESS      => q{MAPPED_ADDRESS};
use constant USERNAME            => q{USERNAME};
use constant MESSAGE_INTEGRITY   => q{MESSAGE_INTEGRITY};
use constant ERROR_CODE          => q{ERROR_CODE};
use constant UNKNOWN_ATTRIBUTES  => q{UNKNOWN_ATTRIBUTES};
use constant REALM               => q{REALM};
use constant NONCE               => q{NONCE};
use constant XOR_MAPPED_ADDRESS  => q{XOR_MAPPED_ADDRESS};
use constant SOFTWARE            => q{SOFTWARE};
use constant ALTERNATE_SERVER    => q{ALTERNATE_SERVER};
use constant FINGERPRINT         => q{FINGERPRINT};

=head2 RFC5766 TURN

=cut

use constant CHANNEL_NUMBER      => q{CHANNEL_NUMBER};
use constant LIFETIME            => q{LIFETIME};
use constant XOR_PEER_ADDRESS    => q{XOR_PEER_ADDRESS};
use constant DATA                => q{DATA};
use constant XOR_RELAYED_ADDRESS => q{XOR_RELAYED_ADDRESS};
use constant EVEN_PORT           => q{EVEN_PORT};
use constant REQUESTED_TRANSPORT => q{REQUESTED_TRANSPORT};
use constant DONT_FRAGMENT       => q{DONT_FRAGMENT};
use constant RESERVATION_TOKEN   => q{RESERVATION_TOKEN};

=head2 RFC5245 ICE

=cut

use constant PRIORITY            => q{PRIORITY};
use constant USE_CANDIDATE       => q{USE_CANDIDATE};
use constant ICE_CONTROLLED      => q{ICE_CONTROLLED};
use constant ICE_CONTROLLING     => q{ICE_CONTROLLING};

=head2 RFC5780 NAT Behavior Discovery

=cut

use constant CHANGE_REQUEST      => q{CHANGE_REQUEST};
use constant RESPONSE_PORT       => q{RESPONSE_PORT};
use constant PADDING             => q{PADDING};
use constant CACHE_TIMEOUT       => q{CACHE_TIMEOUT};
use constant RESPONSE_ORIGIN     => q{RESPONSE_ORIGIN};
use constant OTHER_ADDRESS       => q{OTHER_ADDRESS};

my %ATTR_BIT_MAP = (
    MAPPED_ADDRESS      => 0x0001,
    USERNAME            => 0x0006,
    MESSAGE_INTEGRITY   => 0x0008,
    ERROR_CODE          => 0x0009,
    UNKNOWN_ATTRIBUTES  => 0x000A,
    REALM               => 0x0014,
    NONCE               => 0x0015,
    XOR_MAPPED_ADDRESS  => 0x0020,
    SOFTWARE            => 0x8022,
    ALTERNATE_SERVER    => 0x8023,
    FINGERPRINT         => 0x8028,
    CHANNEL_NUMBER      => 0x000C,
    LIFETIME            => 0x000D,
    XOR_PEER_ADDRESS    => 0x0012,
    DATA                => 0x0013,
    XOR_RELAYED_ADDRESS => 0x0016,
    EVEN_PORT           => 0x0018,
    REQUESTED_TRANSPORT => 0x0019,
    DONT_FRAGMENT       => 0x001A,
    RESERVATION_TOKEN   => 0x0022,
    PRIORITY            => 0x0024,
    USE_CANDIDATE       => 0x0025,
    ICE_CONTROLLED      => 0x8029,
    ICE_CONTROLLING     => 0x802A,
    CHANGE_REQUEST      => 0x0003,
    RESPONSE_PORT       => 0x0027,
    PADDING             => 0x0026,
    CACHE_TIMEOUT       => 0x8027,
    RESPONSE_ORIGIN     => 0x802B,
    OTHER_ADDRESS       => 0x802C,
);

my %REVERSED_ATTR_BIT_MAP = reverse %ATTR_BIT_MAP;

sub get_attribute_bytes {
    my ($self, $type) = @_;
    return $ATTR_BIT_MAP{$type};
}

sub classify_by_bitfield {
    my ($self, $bytes) = @_;
    return $REVERSED_ATTR_BIT_MAP{ $bytes };
}

1;
