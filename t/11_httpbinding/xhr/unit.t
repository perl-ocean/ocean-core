use strict;
use warnings;

use Test::More;

use Ocean::Config;
use Ocean::Config::Schema;
use Ocean::Server;
use Ocean::ServerComponent::Listener::Stub;
use Ocean::ServerComponent::Daemonizer::Null;
use Ocean::CommonComponent::SignalHandler::Stub;
use Ocean::HTTPBinding::StreamManager;
use Ocean::HTTPBinding::StreamFactory::XHR;
use Ocean::Util::SASL::PLAIN qw(build_sasl_plain);
use Ocean::JID;
use Ocean::CommonComponent::Timer::Stub;

use JSON;
use Log::Minimal;

use Ocean::EventDispatcher;
use Ocean::Standalone::Handler::Node;
use Ocean::Standalone::Handler::Authen;
use Ocean::Standalone::Handler::Connection;
use Ocean::Standalone::Handler::Message;
use Ocean::Standalone::Handler::People;
use Ocean::Test::Handler::Message;

use Ocean::Standalone::Context;

my $context = Ocean::Standalone::Context->new;

my $event_dispatcher = Ocean::EventDispatcher->new;
$event_dispatcher->register_handler(node       => Ocean::Standalone::Handler::Node->new      );
$event_dispatcher->register_handler(authen     => Ocean::Standalone::Handler::Authen->new    );
$event_dispatcher->register_handler(connection => Ocean::Standalone::Handler::Connection->new);
$event_dispatcher->register_handler(people     => Ocean::Standalone::Handler::People->new    );
my $handler = Ocean::Test::Handler::Message->new;
$event_dispatcher->register_handler(message    => $handler);


Ocean::Config->initialize(
    path   => q{t/data/config/example.yml},
    schema => Ocean::Config::Schema->config,
);

my $conf = Ocean::Config->instance;
my $log_level = 'MUTE';
local $Log::Minimal::LOG_LEVEL = $log_level;

# Log::Minimal Debug Setting
local $ENV{LM_DEBUG} = 1 
    if $log_level eq 'DEBUG';

#local $Log::Minimal::PRINT = sub {}; # mute

my $listener = Ocean::ServerComponent::Listener::Stub->new(
    host     => $conf->get(server => q{host}),
    port     => $conf->get(server => q{port}),
    backlog  => $conf->get(server => q{backlog}),
    max_read_buffer => $conf->get(server => q{max_read_buffer}),
    timeout  => $conf->get(server => q{timeout}),
);

my $builder         = Ocean::HTTPBinding::StreamFactory::XHR->new;
my $daemonizer      = Ocean::ServerComponent::Daemonizer::Null->new;
my $signal_handler  = Ocean::CommonComponent::SignalHandler::Stub->new;
my $stream_manager  = Ocean::HTTPBinding::StreamManager->new(
    close_on_deliver => 1,
);
my $timer = Ocean::CommonComponent::Timer::Stub->new;

my $server = Ocean::Server->new(
    listener         => $listener,
    stream_factory   => $builder,
    stream_manager   => $stream_manager,
    daemonizer       => $daemonizer,
    signal_handler   => $signal_handler,
    timer            => $timer,
    event_dispatcher => $event_dispatcher,
    context          => $context,
);

$server->initialize();
$server->start();

sub build_http_header {
    my (%params) = @_;
    $params{method} ||= 'GET';
    $params{path}   ||= '/';
    $params{host}   ||= 'sse.example.org';
    $params{origin} ||= 'http://example.org';
    $params{port}   ||= '80';
    $params{huge_header} ||= 0;
    my $header =<<EOF;
$params{method} $params{path} HTTP/1.1
Host: $params{host}:$params{port}
User-Agent: Mozilla/5.0 (Windows; U; Windows NT 5.1; de-DE) 
Accept: application/json
Origin: $params{origin}
Cache-Control: no-cache
Connection: close
EOF

    my @lines = split("\n", $header);
    if ($params{cookie}) {
        push @lines, sprintf('Cookie: %s', $params{cookie});
    }

    if ($params{huge_header}) {
        push @lines, 'X-Huge: ' . '-' x $params{huge_header};
    }

    push(@lines, ("", ""));
    return join("\r\n", @lines);
}

INVALID_DOMAIN: {
    # SETUP dummy client
    my $dummy_fd0 = q{dummy_id_1};
    my $client0 = $listener->emulate_accept($dummy_fd0);
    my @client0_events;
    $client0->client_on_read(sub { push(@client0_events, $_[0]) });

    my $header = &build_http_header(host => 'invalid.domain.example.org');
    $client0->emulate_client_write($header);
    like($client0_events[0], qr|^HTTP/1.1 400 Bad Request|, 'invalid domain');
}

INVALID_HEADER: {
    # SETUP dummy client1
    my $dummy_fd0 = q{dummy_id_0};
    my $client0 = $listener->emulate_accept($dummy_fd0);
    my @client0_events;
    $client0->client_on_read(sub { push(@client0_events, $_[0]) });

    my $header = &build_http_header(method => 'DELETE');
    $client0->emulate_client_write($header);
    like($client0_events[0], qr|^HTTP/1.1 400 Bad Request|, 'bad request');
    ok($client0->is_closed(), "connection should be closed");
}

HUGE_HEADER: {
    # SETUP dummy client1
    my $dummy_fd0 = q{dummy_id_0};
    my $client0 = $listener->emulate_accept($dummy_fd0);
    my @client0_events;
    $client0->client_on_read(sub { push(@client0_events, $_[0]) });

    my $header = &build_http_header(huge_header => 1024*10 );
    $client0->emulate_client_write($header);
    like($client0_events[0], qr|^HTTP/1.1 400 Bad Request|, 'bad request (long header)');
    like($client0_events[0], qr|X-Ocean-Error: long header|, 'bad request reason (long header)');
    ok($client0->is_closed(), "connection should be closed");
}

NON_COOKIE: {
    # SETUP dummy client1
    my $dummy_fd1 = q{dummy_id_1};
    my $client1 = $listener->emulate_accept($dummy_fd1);
    my @client1_events;
    $client1->client_on_read(sub { push(@client1_events, $_[0]) });

    my $header = &build_http_header();
    $client1->emulate_client_write($header);
    like($client1_events[0], qr|^HTTP/1.1 401 Unauthorized|, 'non cookie request');
    ok($client1->is_closed(), "connection should be closed");
}

INVALID_COOKIE: {
    # SETUP dummy client1
    my $dummy_fd1 = q{dummy_id_1};
    my $client1 = $listener->emulate_accept($dummy_fd1);
    my @client1_events;
    $client1->client_on_read(sub { push(@client1_events, $_[0]) });

    my $header = &build_http_header(cookie => 'foo="bar"; bar=baz;');
    $client1->emulate_client_write($header);
    like($client1_events[0], qr|^HTTP/1.1 401 Unauthorized|, 'invalid cookie request');
    ok($client1->is_closed(), "connection should be closed");
}

my ($client1, $client2, $client3, $client4);
my (@client1_events, @client2_events, @client3_events, @client4_events);

VALID_COOKIE: {
    my $dummy_fd1 = q{dummy_id_1};
    $client1 = $listener->emulate_accept($dummy_fd1);
    $client1->client_on_read(sub { push(@client1_events, $_[0]) });

    my $header = &build_http_header(cookie => 'foo="tarotaro"; bar=baz;');
    $client1->emulate_client_write($header);
    is(scalar(@client1_events), 0, 'client1 events should be 0');
    ok(!$client1->is_closed(), q{Clinet1 is suspended});
}

APPEND_ONE_MORE_VALID_CONNECTION: {
    my $dummy_fd2 = q{dummy_id_2};
    $client2 = $listener->emulate_accept($dummy_fd2);
    $client2->client_on_read(sub { push(@client2_events, $_[0]) });

    my $header = &build_http_header(cookie => 'foo="tarotaro"; bar=baz;');
    $client2->emulate_client_write($header);
    is(scalar(@client1_events), 0, 'client2 events should be 0');
    ok(!$client2->is_closed(), q{Clinet2 is suspended});
}

# connect another user
CONNECT_ANOTHER_USER: {
    my $dummy_fd3 = q{dummy_id_3};
    $client3 = $listener->emulate_accept($dummy_fd3);
    $client3->client_on_read(sub { push(@client3_events, $_[0]) });

    my $header = &build_http_header(cookie => 'foo=jirojiro;');
    $client3->emulate_client_write($header);

    ok(!$client3->is_closed(), q{Clinet3 is suspended});
    is(scalar(@client3_events), 0, 'client3 events should be 0');

    # check if initial presence is broadcasted correctly
    is(scalar(@client1_events), 2, 'client1 events should be 2');
    like($client1_events[0], qr|^HTTP/1.1 200 OK|);
    like($client1_events[0], qr|Set-Cookie: foo=tarotaro|);
    like($client1_events[0], qr|X-Ocean-Test: foobar|);
    like($client1_events[1], qr|\{\"presence\"\:\{\"show\"\:\"chat\"\,\"to\"\:\"taro|);
    like($client1_events[1], qr|\"from\"\:\"jiro|);
    ok($client1->is_closed(), q{Clinet1 should be closed});

    is(scalar(@client2_events), 2, 'client2 events should be 2');
    like($client2_events[0], qr|^HTTP/1.1 200 OK|);
    like($client2_events[0], qr|Set-Cookie: foo=tarotaro|);
    like($client2_events[0], qr|X-Ocean-Test: foobar|);
    like($client2_events[1], qr|\{\"presence\"\:\{\"show\"\:\"chat\"\,\"to\"\:\"taro|);
    like($client2_events[1], qr|\"from\"\:\"jiro|);
    ok($client2->is_closed(), q{Clinet2 should be closed});
}

#use Data::Dump qw(dump);
#warn "CLIENT1";
#warn dump(\@client1_events);
#warn "CLIENT2";
#warn dump(\@client2_events);
#warn "CLIENT3";
#warn dump(\@client3_events);

done_testing;
