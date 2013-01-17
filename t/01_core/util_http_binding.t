use strict;
use warnings;

use Test::More;
use Test::Exception;

use Ocean::Config;
use Ocean::Config::Schema;

use Ocean::Util::HTTPBinding qw(parse_host check_host);

Ocean::Config->initialize(
    path   => q{t/data/config/example.yml},
    schema => Ocean::Config::Schema->config,
);

is parse_host('xmpp.example.org'), 'xmpp.example.org', 'without port';
is parse_host('xmpp.example.org:80'), 'xmpp.example.org', 'with port';

is check_host(undef, 'xmpp.example.org'), 'xmpp.example.org', 'check host';
is check_host(undef, 'xmpp.example.org:8080'), 'xmpp.example.org', 'check host with port';

throws_ok {
    check_host(undef, 'not.in.config.example.org');
} 'Ocean::Error::HTTPHandshakeError', 'host not in config';

is $@, 'Bad Request: error', 'host not in config exception';

done_testing;
