use strict;
use warnings;

use Test::More;
use Test::Exception;

use Ocean::Config;
use Ocean::Config::Schema;

use Ocean::Util::HTTPBinding qw(parse_uri_from_request check_host);

use HTTP::Parser::XS qw(parse_http_request);
use URI::QueryParam;

Ocean::Config->initialize(
    path   => q{t/data/config/example.yml},
    schema => Ocean::Config::Schema->config,
);

is check_host(undef, 'xmpp.example.org'), 'xmpp.example.org', 'check host';

throws_ok {
    check_host(undef, 'not.in.config.example.org');
} 'Ocean::Error::HTTPHandshakeError', 'host not in config';

is $@, 'Bad Request: error', 'host not in config exception';

# tests for parsing uri from request
my $req_header = <<EOF;
GET /path?foo=bar&hoge=fuga HTTP/1.1
Host: example.org:80
User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; de-DE) 
Accept-Encoding: gzip, deflate
Accept: text/event-stream
Cache-Control: no-cache
Connection: keep-alive

EOF

my $env = {};
my $ret = parse_http_request($req_header, $env);

cmp_ok $ret, '>=', 0, 'parsed request';

my $uri = parse_uri_from_request($env);
is($uri->host, 'example.org', 'parsed request uri host');
is($uri->port, 80, 'parsed request uri port');
is($uri->path, '/path', 'parsed request uri path');
is($uri->query_param('foo'), 'bar', 'parsed param foo');
is($uri->query_param('hoge'), 'fuga', 'parsed param hoge');

done_testing;
