package Ocean::Jingle::STUN::MethodType;

use strict;
use warnings;

use Ocean::Jingle::STUN::ClassType qw(INDICATION);

use base 'Exporter';

our %EXPORT_TAGS = (all => [qw(
    BINDING
    ALLOCATE
    REFRESH
    SEND
    DATA
    CREATE_PERMISSION
    CHANNEL_BIND
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

use constant BINDING           => 'BINDING';           # request/response, indication
use constant ALLOCATE          => 'ALLOCATE';          # request/response
use constant REFRESH           => 'REFRESH';           # request/response
use constant SEND              => 'SEND';              # indication
use constant DATA              => 'DATA';              # indication
use constant CREATE_PERMISSION => 'CREATE_PERMISSION'; # request/response
use constant CHANNEL_BIND      => 'CHANNEL_BIND';      # request/response

#use constant BINDING           => '000000000001'; # request/response, indication
#use constant ALLOCATE          => '000000000011'; # request/response
#use constant REFRESH           => '000000000100'; # request/response
#use constant SEND              => '000000000110'; # indication
#use constant DATA              => '000000000111'; # indication
#use constant CREATE_PERMISSION => '000000001000'; # request/response
#use constant CHANNEL_BIND      => '000000001001'; # request/response

my %METHOD_BITS_MAP = (
    BINDING           => 0b0000000000000001,
    ALLOCATE          => 0b0000000000000011,
    REFRESH           => 0b0000000000000100,
    SEND              => 0b0000000000000110,
    DATA              => 0b0000000000000111,
    CREATE_PERMISSION => 0b0000000000001000,
    CHANNEL_BIND      => 0b0000000000001001,
);

my %REVERSED_METHOD_BITS_MAP = reverse %METHOD_BITS_MAP;

sub classify_by_message_type_field {
    my ($class, $message_type_field) = @_;
    my $method_bits = $message_type_field & 0b0011111011101111;
    return $REVERSED_METHOD_BITS_MAP{ $method_bits };
}

sub get_method_bits {
    my ($class, $type) = @_;
    return $METHOD_BITS_MAP{$type};
}

my %REQ_RES_METHODS = (
    BINDING()           => 1,
    REFRESH()           => 1,
    CREATE_PERMISSION() => 1,
    CHANNEL_BIND()      => 1,
);

my %INDICATION_METHODS = (
    BINDING()           => 1,
    SEND()              => 1,
    DATA()              => 1,
);

sub is_valid_method {
    my ($klass, $class, $method) = @_;
    if ($class == INDICATION) {
        return exists $INDICATION_METHODS{$method};
    } else {
        return exists $REQ_RES_METHODS{$method};
    }
}

1;
