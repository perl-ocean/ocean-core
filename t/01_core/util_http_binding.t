use strict;
use warnings;

use Test::More;
use Ocean::Util::HTTPBinding qw(parse_host);

is(parse_host('xmpp.example.org'), 'xmpp.example.org', 'without port');
is(parse_host('xmpp.example.org:80'), 'xmpp.example.org', 'with port');

done_testing;
