package Ocean::Util::SASL::PLAIN;

use strict;
use warnings;

use base 'Exporter';
use MIME::Base64 qw(
    encode_base64 
    decode_base64 
);

our %EXPORT_TAGS = (all => [qw(
    parse_sasl_plain
    parse_sasl_plain_b64
    build_sasl_plain
    build_sasl_plain_b64
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

sub parse_sasl_plain {
    my $str = shift;
    my ($authzid, $username, $password) = split(/\0/, $str);
    return ($username, $password);
}

sub parse_sasl_plain_b64 {
    my $str = shift;
    chomp $str;
    $str = decode_base64($str);
    return parse_sasl_plain($str);
}

sub build_sasl_plain {
    my ($username, $password) = @_;
    return join("\0", '', $username, $password);
}

sub build_sasl_plain_b64 {
    my ($username, $password) = @_;
    my $text = build_sasl_plain($username, $password);
    $text = encode_base64($text);
    chomp $text;
    return $text;
}

1;
