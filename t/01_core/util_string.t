use strict;
use warnings;

use Test::More;
use Ocean::Util::String qw(gen_random trim camelize);

my $stream_id = gen_random(10);
like($stream_id, qr/^[a-zA-Z0-9]{10}$/, 'random test');

my $trim = trim(' ho ge   ');
is($trim, 'ho ge', 'crrect trimming');

my $camel = camelize(' mY sErVice  ');
is($camel, 'MyService');

done_testing;
