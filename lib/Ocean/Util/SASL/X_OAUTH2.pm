package Ocean::Util::SASL::X_OAUTH2;

use strict;
use warnings;

use base 'Exporter';
use MIME::Base64 qw(
    encode_base64
    decode_base64
);

our %EXPORT_TAGS = (all => [qw(
    parse_sasl_x_oauth2
    parse_sasl_x_oauth2_b64
    build_sasl_x_oauth2
    build_sasl_x_oauth2_b64
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

sub parse_sasl_x_oauth2 {
    my $str = shift;
    my ($authzid, $username, $oauth_token) = split(/\0/, $str);
    return ($username, $oauth_token);
}

sub parse_sasl_x_oauth2_b64 {
    my $str = shift;
    chomp $str;
    $str = decode_base64($str);
    return parse_sasl_x_oauth2($str);
}

sub build_sasl_x_oauth2 {
    my ($username, $oauth_token) = @_;
    return join("\0", '', $username, $oauth_token);
}

sub build_sasl_x_oauth2_b64 {
    my ($username, $oauth_token) = @_;
    my $text = build_sasl_x_oauth2($username, $oauth_token);
    $text = encode_base64($text);
    chomp $text;
    return $text;
}

1;
