use strict;
use warnings;

use Test::More tests => 12;

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
    process_manager   => $process_manager,
    deliverer         => $deliverer,
    fetcher           => $fetcher,
    serializer        => $serializer, 
    signal_handler    => $signal_handler,
    max_job_per_child => 5,
    event_dispatcher  => $event_dispatcher,
    context           => $context,
);

$service->service_initialize();
$service->work();

sub handle_sasl_job {
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

&handle_sasl_job();
&handle_sasl_job();
&handle_sasl_job();
&handle_sasl_job();

ok(!$fetcher->is_required_to_stop(), "fetcher shouldn't be reuiqred to stop");

&handle_sasl_job();

ok($fetcher->is_required_to_stop(), "fetcher should be reuiqred to stop");

#$service->service_finalize();


