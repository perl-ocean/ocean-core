use strict;
use warnings;

use Test::More tests => 6;
use Ocean::Util::SASL::PLAIN qw(
    parse_sasl_plain 
    parse_sasl_plain_b64
    build_sasl_plain
    build_sasl_plain_b64
);

my $username = "foobar";
my $password = "buzbuz";
my $message = build_sasl_plain($username, $password);
is($message, "\0foobar\0buzbuz");

my ($username2, $password2) = parse_sasl_plain($message);
is($username2, 'foobar');
is($password2, 'buzbuz');

my $message64 = build_sasl_plain_b64($username, $password);
is($message64, "AGZvb2JhcgBidXpidXo=");

my ($username3, $password3) = parse_sasl_plain_b64($message64);
is($username3, 'foobar');
is($password3, 'buzbuz');

