package Ocean::Jingle::STUN::Util;

use strict;
use warnings;

use base 'Exporter';
use Authen::SASL::SASLprep;
use Digest::MD5;
use Digest::SHA;
use String::CRC32;

our %EXPORT_TAGS = (all => [qw(
    calc_fingerprint
    calc_message_integrity
    gen_long_term_key
    gen_short_term_key
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

sub calc_fingerprint {
    my ($bytes) = @_;
    return String::CRC32::crc32($bytes);
}

sub calc_message_integrity {
    my ($bytes, $key) = @_;
    return Digest::SHA::hmac_sha1($bytes, $key);
}

sub gen_long_term_key {
    my ($username, $realm, $password) = @_;
    return Digest::MD5::md5(join ':', 
        $username, 
        $realm, 
        Authen::SASL::SASLprep::saslprep($password))
}

sub gen_short_term_key {
    my $password = shift;
    return Authen::SASL::SASLprep::saslprep($password);
}

1;
