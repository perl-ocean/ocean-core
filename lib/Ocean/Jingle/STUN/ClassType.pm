package Ocean::Jingle::STUN::ClassType;

use strict;
use warnings;

use base 'Exporter';

our %EXPORT_TAGS = (all => [qw(
    REQUEST
    INDICATION
    RESPONSE_SUCCESS
    RESPONSE_ERROR
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

use constant REQUEST          => q{REQUEST};
use constant INDICATION       => q{INDICATION};
use constant RESPONSE_SUCCESS => q{RESPONSE_SUCCESS};
use constant RESPONSE_ERROR   => q{RESPONSE_ERROR};

my %CLASS_BITS_MAP = (
    REQUEST          => 0b0000000000000000,
    INDICATION       => 0b0000000000010000,
    RESPONSE_SUCCESS => 0b0000000100000000,
    RESPONSE_ERROR   => 0b0000000100010000,
);

my %REVERSED_CLASS_BITS_MAP = reverse %CLASS_BITS_MAP;

sub classify_by_message_type_field {
    my ($class, $message_type_field) = @_;
    my $class_bits = $message_type_field & 0b0000000100010000;
    return $REVERSED_CLASS_BITS_MAP{ $class_bits };
}

sub get_class_bits {
    my ($class, $type) = @_;
    return $CLASS_BITS_MAP{$type};
}

1;
