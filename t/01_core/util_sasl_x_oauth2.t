use strict;
use warnings;

use Test::More tests => 6;
use Ocean::Util::SASL::X_OAUTH2 qw(
    parse_sasl_x_oauth2
    parse_sasl_x_oauth2_b64
    build_sasl_x_oauth2
    build_sasl_x_oauth2_b64
);

my $username    = "foobar";
my $oauth_token = "buzbuz";
my $message = build_sasl_x_oauth2($username, $oauth_token);
is($message, "\0foobar\0buzbuz");

my ($username2, $oauth_token2) = parse_sasl_x_oauth2($message);
is($username2, 'foobar');
is($oauth_token2, 'buzbuz');

my $message64 = build_sasl_x_oauth2_b64($username, $oauth_token);
is($message64, "AGZvb2JhcgBidXpidXo=");

my ($username3, $oauth_token3) = parse_sasl_x_oauth2_b64($message64);
is($username3, 'foobar');
is($oauth_token3, 'buzbuz');

