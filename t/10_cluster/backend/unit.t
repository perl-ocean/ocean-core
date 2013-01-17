use strict;
use warnings;

use Test::More tests => 14;

use Ocean::Constants::EventType;
use Ocean::CommonComponent::SignalHandler::Stub;
use Ocean::Cluster::Backend::ProcessManager::Single;
use Ocean::Cluster::Backend::Service;
use Ocean::Cluster::Backend::EventDispatcher;
use Ocean::Cluster::Backend::Deliverer::Stub;
use Ocean::Cluster::Backend::Fetcher::Stub;
use Ocean::Cluster::Serializer::Storable;
use Ocean::Cluster::Serializer::JSON;
use Ocean::Util::SASL::PLAIN qw(build_sasl_plain_b64);
use Ocean::Config;
use Ocean::Cluster::Backend::Config::Schema;

use Ocean::Standalone::Cluster::Backend::Context;

use Ocean::Standalone::Cluster::Backend::Handler::Node;
use Ocean::Standalone::Cluster::Backend::Handler::Authen;
use Ocean::Standalone::Cluster::Backend::Handler::Connection;
use Ocean::Standalone::Cluster::Backend::Handler::Message;
use Ocean::Standalone::Cluster::Backend::Handler::People;
use Ocean::Standalone::Cluster::Backend::Handler::Worker;
use Ocean::Standalone::Cluster::Backend::Handler::PubSub;
use Ocean::Standalone::Cluster::Backend::Handler::P2P;
use Ocean::Standalone::Cluster::Backend::Handler::Room;

Ocean::Config->initialize(
    path   => q{t/data/config/worker_example.yml},
    schema => Ocean::Cluster::Backend::Config::Schema->config,
);


use Log::Minimal;
local $Log::Minimal::LOG_LEVEL = 'MUTE';
#local $Log::Minimal::LOG_LEVEL = 'DEBUG';

# Log::Minimal Debug Setting
local $ENV{LM_DEBUG} = 1 
    if $Log::Minimal::LOG_LEVEL eq 'DEBUG';

my $serializer      = Ocean::Cluster::Serializer::JSON->new;
my $process_manager = Ocean::Cluster::Backend::ProcessManager::Single->new;
my $deliverer       = Ocean::Cluster::Backend::Deliverer::Stub->new;

my $context = Ocean::Standalone::Cluster::Backend::Context->new;
my $event_dispatcher = Ocean::Cluster::Backend::EventDispatcher->new;
$event_dispatcher->register_handler(node       => Ocean::Standalone::Cluster::Backend::Handler::Node->new      );
$event_dispatcher->register_handler(authen     => Ocean::Standalone::Cluster::Backend::Handler::Authen->new    );
$event_dispatcher->register_handler(message    => Ocean::Standalone::Cluster::Backend::Handler::Message->new   );
$event_dispatcher->register_handler(connection => Ocean::Standalone::Cluster::Backend::Handler::Connection->new);
$event_dispatcher->register_handler(people     => Ocean::Standalone::Cluster::Backend::Handler::People->new    );
$event_dispatcher->register_handler(worker     => Ocean::Standalone::Cluster::Backend::Handler::Worker->new    );
$event_dispatcher->register_handler(pubsub     => Ocean::Standalone::Cluster::Backend::Handler::PubSub->new    );
$event_dispatcher->register_handler(p2p        => Ocean::Standalone::Cluster::Backend::Handler::P2P->new       );
$event_dispatcher->register_handler(room       => Ocean::Standalone::Cluster::Backend::Handler::Room->new      );

my $fetcher = 
    Ocean::Cluster::Backend::Fetcher::Stub->new(
        serializer => $serializer, 
    );

my $signal_handler = Ocean::CommonComponent::SignalHandler::Stub->new;

my $service = Ocean::Cluster::Backend::Service->new(
    process_manager  => $process_manager,
    deliverer        => $deliverer,
    fetcher          => $fetcher,
    serializer       => $serializer, 
    signal_handler   => $signal_handler,
    event_dispatcher => $event_dispatcher,
    context          => $context,
);

$service->service_initialize();
$service->work();

TEST_INVALID_AUTH_TEXT: {
    $fetcher->emulate_job(
        type    => Ocean::Constants::EventType::SASL_AUTH_REQUEST,
        node_id => 'node00',
        args  => {
            stream_id => q{taro00}, 
            mechanism => q{PLAIN}, 
            text      => q{hoge},
        },
    );

    my $req1 = $deliverer->pop_deliver_request();
    is($req1->{host}, 'node00');
    is($req1->{data}, '{"args":{"stream_id":"taro00"},"type":"sasl_auth_failure"}');
}

TEST_INVALID_AUTH_MECH: {
    $fetcher->emulate_job(
        type    => Ocean::Constants::EventType::SASL_AUTH_REQUEST,
        node_id => 'node00',
        args  => {
            stream_id => q{taro00}, 
            mechanism => q{UNKNOWN}, 
            text      => q{hoge},
        },
    );

    my $req1 = $deliverer->pop_deliver_request();
    is($req1->{host}, 'node00');
    is($req1->{data}, '{"args":{"stream_id":"taro00"},"type":"sasl_auth_failure"}');
}


TEST_VALID_AUTH: {
    $fetcher->emulate_job(
        type    => Ocean::Constants::EventType::SASL_AUTH_REQUEST,
        node_id => 'node00',
        args  => {
            stream_id => q{taro00}, 
            mechanism => q{PLAIN}, 
            text      => build_sasl_plain_b64(q{taro}, q{tarotaro}),
        },
    );
    my $req1 = $deliverer->pop_deliver_request();
    is($req1->{host}, 'node00');
    #is($req1->{data}, '{"args":{"user_id":0,"stream_id":"taro00"},"type":"sasl_auth_completion"}');
    like($req1->{data}, qr/\{\"args\"\:\{\"session_id\"\:\"[a-zA-Z0-9]+\"\,\"user_id\"\:0\,\"username\"\:\"taro\"\,\"stream_id\"\:\"taro00\"\}\,\"type\"\:\"sasl_auth_completion\"\}/);
}

TEST_RESOURCE_BINDING: {
    $fetcher->emulate_job(
        type    => Ocean::Constants::EventType::BIND_REQUEST,
        node_id => 'node00',
        args  => {
            stream_id   => 'taro00',
            user_id     => '0',
            domain      => 'xmpp.example.org',
            want_extval => '1',
            resource    => 'foobar',
        },
    );
    my $req1 = $deliverer->pop_deliver_request();
    is($req1->{host}, 'node00');
    like($req1->{data}, qr|{"args":{"nickname":"Taro","jid":"taro\@xmpp\.example\.org/foobar","stream_id":"taro00"},"type":"bound_jid"}|);
}

TEST_RESOURCE_BINDING_WITHOUT_RESOURCE: {
    $fetcher->emulate_job(
        type    => Ocean::Constants::EventType::BIND_REQUEST,
        node_id => 'node00',
        args  => {
            stream_id   => 'taro00',
            user_id     => '0',
            want_extval => '1',
        },
    );
    my $req1 = $deliverer->pop_deliver_request();
    ok(!$req1);
    #is($req1->{host}, 'node00');
    #like($req1->{data}, qr|{"args":{"nickname":"Taro","jid":"taro\@xmpp\.example\.org/[0-9a-fA-F]+","stream_id":"taro00"},"type":"bound_jid"}|);
}

TEST_RESOURCE_BINDING_WITHOUT_EXTVAL: {
    $fetcher->emulate_job(
        type    => Ocean::Constants::EventType::BIND_REQUEST,
        node_id => 'node01',
        args  => {
            stream_id   => 'jiro00',
            user_id     => '1',
            want_extval => '0',
            domain      => 'xmpp.example.org',
            resource    => 'foobar',
        },
    );
    my $req1 = $deliverer->pop_deliver_request();
    is($req1->{host}, 'node01');
    like($req1->{data}, qr|{"args":{"jid":"jiro\@xmpp\.example\.org/foobar","stream_id":"jiro00"},"type":"bound_jid"}|);
}

TEST_RESOURCE_BINDING_UNKOWN_USER: {
    $fetcher->emulate_job(
        type    => Ocean::Constants::EventType::BIND_REQUEST,
        node_id => 'node00',
        args  => {
            stream_id   => 'unknown00',
            user_id     => '10000000',
            want_extval => '1',
        },
    );
    my $req1 = $deliverer->pop_deliver_request();
    ok(!$req1);
}

TEST_PUBSUB_EVENT: {
    $fetcher->emulate_job(
        type    => Ocean::Constants::EventType::PUBLISH_EVENT,
        node_id => '__NOT_USED__',
        args  => {
            from => q{pubsub.xmpp.example.org},
            to   => q{jiro@xmpp.example.org},
            node => q{activity},
            items => [
                {
                    id        => 'activity_01', 
                    name      => 'photo',
                    namespace => 'http://example.org/ns#photo',
                    fields    => {
                        user_id => 100, 
                        summary => q{John uploaded new photo},
                    },
                }, 
                {
                    id        => 'activity_02', 
                    name      => 'note',
                    namespace => 'http://example.org/ns#note',
                    fields    => {
                        user_id => 101, 
                        summary => q{Ken wrote new note},
                    },
                }, 
            ],
        },
    );
    my $req1 = $deliverer->pop_deliver_request();
    is($req1->{host}, 'node01');
    my $result = '{"args":{"to":"jiro@xmpp.example.org/foobar","from":"pubsub.xmpp.example.org","node":"activity","items":[{"fields":{"summary":"John uploaded new photo","user_id":100},"namespace":"http://example.org/ns#photo","name":"photo","id":"activity_01"},{"fields":{"summary":"Ken wrote new note","user_id":101},"namespace":"http://example.org/ns#note","name":"note","id":"activity_02"}]},"type":"deliver_pubsub_event"}';
    #my $result = quotemeta '{"args":{"to":"jiro@xmpp.example.org","from":"pubsub.xmpp.example.org","node":"activity","items":[{"fields":{"summary":"John uploaded new photo","user_id":100},"namespace":"http://example.org/ns#photo","name":"photo","id":"activity_01"},{"fields":{"summary":"Ken wrote new note","user_id":101},"namespace":"http://example.org/ns#note","name":"note","id":"activity_02"}]},"type":"deliver_pubsub_event"}';

    #$result =~ s|jiro\\\@xmpp\\\.example\\\.org|jiro\@xmpp.example.org/[0-9a-fA-F]+|;

    is($req1->{data}, $result);
}

