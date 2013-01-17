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
use Ocean::HTTPBinding::StreamFactory::WebSocket;
use Ocean::Util::SASL::PLAIN qw(build_sasl_plain);

use Ocean::CommonComponent::Timer::Stub;

use Protocol::WebSocket::Request;
use Protocol::WebSocket::Frame;

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

my $builder         = Ocean::HTTPBinding::StreamFactory::WebSocket->new;
my $daemonizer      = Ocean::ServerComponent::Daemonizer::Null->new;
my $signal_handler  = Ocean::CommonComponent::SignalHandler::Stub->new;
my $stream_manager  = Ocean::HTTPBinding::StreamManager->new;
my $timer           = Ocean::CommonComponent::Timer::Stub->new;

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
    $params{host}   ||= 'xmpp.example.org';
    $params{path}   ||= '/path';

    my $header = Protocol::WebSocket::Request->new(
        host          => $params{host},
        resource_name => $params{path},
    );
    my $str = $header->to_string();
    if ($params{cookie}) {
        my @lines = split("\r\n", $str);
        return join("\r\n", (@lines[0..$#lines-1], sprintf('Cookie: %s', $params{cookie}), ""))."\r\n";
    } else {
        return $str;
    }
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

NON_COOKIE: {
    # SETUP dummy client1
    my $dummy_fd1 = q{dummy_id_1};
    my $client1 = $listener->emulate_accept($dummy_fd1);
    my @client1_events;
    $client1->client_on_read(sub { push(@client1_events, $_[0]) });

    my $header = &build_http_header();
    $client1->emulate_client_write($header);
    like($client1_events[0], qr|^HTTP/1.1 401 Unauthorized|, 'non cookie request');
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
}

my ($client1, $client2, $client3, $client4);
my (@client1_events, @client2_events, @client3_events, @client4_events);

VALID_COOKIE: {
    my $dummy_fd1 = q{dummy_id_1};
    $client1 = $listener->emulate_accept($dummy_fd1);
    $client1->client_on_read(sub { push(@client1_events, $_[0]) });

    my $header = &build_http_header(cookie => 'foo="tarotaro"; bar=baz;');
    $client1->emulate_client_write($header);
    like($client1_events[0], qr|^HTTP/1.1 101 Switching Protocols|);
    is(scalar(@client1_events), 1, 'client1 events should be 1');
}

APPEND_ONE_MORE_VALID_CONNECTION: {
    my $dummy_fd2 = q{dummy_id_2};
    $client2 = $listener->emulate_accept($dummy_fd2);
    $client2->client_on_read(sub { push(@client2_events, $_[0]) });

    my $header = &build_http_header(cookie => 'foo="tarotaro"; bar=baz;');
    $client2->emulate_client_write($header);
    like($client2_events[0], qr|^HTTP/1.1 101 Switching Protocols|);
    is(scalar(@client2_events), 1, 'client2 events should be 1');
}

# connect another user
CONNECT_ANOTHER_USER: {
    my $dummy_fd3 = q{dummy_id_3};
    $client3 = $listener->emulate_accept($dummy_fd3);
    $client3->client_on_read(sub { push(@client3_events, $_[0]) });

    my $header = &build_http_header(cookie => 'foo=jirojiro;');
    $client3->emulate_client_write($header);
    like($client3_events[0], qr|^HTTP/1.1 101 Switching Protocols|);

    # check if initial presence is broadcasted correctly
    is(scalar(@client1_events), 2, 'client1 events should be 2');
    like($client1_events[1], qr|\{\"presence\"\:\{\"show\"\:\"chat\"\,\"to\"\:\"taro|);
    like($client1_events[1], qr|\"from\"\:\"jiro|);

    is(scalar(@client2_events), 2, 'client2 events should be 2');
    like($client2_events[1], qr|\{\"presence\"\:\{\"show\"\:\"chat\"\,\"to\"\:\"taro|);
    like($client2_events[1], qr|\"from\"\:\"jiro|);

    is(scalar(@client3_events), 2, 'client3 events should be 2');
    like($client3_events[1], qr|\{\"presence\"\:\{\"show\"\:\"chat\"\,\"to\"\:\"jiro|);
    like($client3_events[1], qr|\"from\"\:\"taro|);
}

SEND_MESSAGE: {
    my $message = {
        message => {
            to   => 'taro@xmpp.example.org',
            body => "hoge",
        }, 
    };
    my $frame = Protocol::WebSocket::Frame->new(JSON->new->utf8(1)->encode($message));
    $client3->emulate_client_write($frame->to_bytes);
    is(scalar(@client1_events), 3, 'client1 events should be 3');
    like($client1_events[2], qr|\{\"message\"\:\{\"body\"\:\"hoge\"|);
    is(scalar(@client2_events), 3, 'client2 events should be 3');
    like($client2_events[2], qr|\{\"message\"\:\{\"body\"\:\"hoge\"|);
    is(scalar(@client3_events), 2, 'client3 events should be 2');
}

SEND_INVALID_MESSAGE: {
    my $message = {
        message => {
            to   => 'unknown@xmpp.example.org',
            body => "foo",
        }, 
    };
    my $frame = Protocol::WebSocket::Frame->new(JSON->new->utf8(1)->encode($message));
    $client3->emulate_client_write($frame->to_bytes);
    # doesn't change
    is(scalar(@client1_events), 3, 'client1 events should be 3');
    is(scalar(@client2_events), 3, 'client2 events should be 3');
    is(scalar(@client3_events), 2, 'client3 events should be 2');
}

SEND_MESSAGE_FROM_CLIENT1: {
    my $message = {
        message => {
            to   => 'jiro@xmpp.example.org',
            body => "bar",
        }, 
    };
    my $frame = Protocol::WebSocket::Frame->new(JSON->new->utf8(1)->encode($message));
    $client1->emulate_client_write($frame->to_bytes);
    is(scalar(@client1_events), 3, 'client1 events should be 3');
    is(scalar(@client2_events), 3, 'client2 events should be 3');
    is(scalar(@client3_events), 3, 'client3 events should be 3');

    like($client3_events[2], qr|\{\"message\"\:\{\"body\"\:\"bar\"|);
}

SEND_MESSAGE_FROM_CLIENT2: {
    my $message = {
        message => {
            to   => 'jiro@xmpp.example.org',
            body => "buz",
        }, 
    };
    my $frame = Protocol::WebSocket::Frame->new(JSON->new->utf8(1)->encode($message));
    $client2->emulate_client_write($frame->to_bytes);
    is(scalar(@client1_events), 3, 'client1 events should be 3');
    is(scalar(@client2_events), 3, 'client2 events should be 3');
    is(scalar(@client3_events), 4, 'client3 events should be 4');

    like($client3_events[3], qr|\{\"message\"\:\{\"body\"\:\"buz\"|);
}

CLOSE_CLIENT2: {
    $client2->close();
    # doesn't change
    is(scalar(@client1_events), 3, 'client1 events should be 3');
    is(scalar(@client3_events), 4, 'client3 events should be 4');
}

CLOSE_CLIENT1: {
    $client1->close();
    # doesn't change
    is(scalar(@client3_events), 4, 'client3 events should be 4');
}

RECOVER_BEFORE_TIMEOUT: {
    my $dummy_fd4 = q{dummy_id_4};
    $client4 = $listener->emulate_accept($dummy_fd4);
    $client4->client_on_read(sub { push(@client4_events, $_[0]) });

    my $header = &build_http_header(cookie => 'foo=tarotaro');
    $client4->emulate_client_write($header);
    like($client4_events[0], qr|^HTTP/1.1 101 Switching Protocols|);

    # doesn't change
    is(scalar(@client3_events), 4, 'client3 events should be 4');
}

CLOSE_CLIENT4: {
    $client4->close();
    # doesn't change
    is(scalar(@client3_events), 4, 'client3 events should be 4');
    use Coro::Timer;
    Coro::Timer::sleep(5);
    is(scalar(@client3_events), 5, 'client3 events should be 5');

    # taro executed shutdown correctly
    like($client3_events[4], qr|\{\"unavailable_presence\"\:\{|);
}



#use Data::Dump qw(dump);
#warn "CLIENT1";
#warn dump(\@client1_events);
#warn "CLIENT2";
#warn dump(\@client2_events);
#warn "CLIENT3";
#warn dump(\@client3_events);

done_testing;
