package Ocean::Util::JID;

use strict;
use warnings;

use base 'Exporter';
use Ocean::JID;

our %EXPORT_TAGS = (all => [qw(
    to_jid
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

sub to_jid {
    my ($address) = @_;
    return (!$address)
        ? ""
        : $address->isa("Ocean::JID") 
            ? $address
            : Ocean::JID->new($address);
}

