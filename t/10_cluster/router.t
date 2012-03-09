use strict;
use warnings;

use Test::More;

use Ocean::Cluster::Frontend::Router;
use Ocean::Cluster::Frontend::RouterEvaluator;
use Try::Tiny;
use Ocean::Constants::EventType;


my $router = Ocean::Cluster::Frontend::Router->new;
$router->register_broker(broker01 => ["127.0.0.2:10000"]);
$router->register_broker(broker02 => ["127.0.0.3:10000"]);
$router->register_broker(broker03 => ["192.168.0.1:1111"]);
$router->register_broker(broker04 => ["192.168.0.1:1112"]);
$router->register_broker(broker05 => ["192.168.0.1:1113"]);
$router->register_broker(broker06 => ["192.168.10.10:10"]);

# INVALID EVENT NAME
my $err;
try {
    $router->event_route('invalid' => {
        broker => q{broker01},     
        queue  => q{hoge_queue},
    });
} catch {
    $err = $_;
};
ok($err, "Invalid Event Name");

$err = undef;
try {
    # HASH style matcher
    $router->event_route('sasl_auth' => {
        broker => q{broker01},     
        queue  => q{hoge_queue},
    });
} catch {
    $err = $_;
};
ok(!$err, "Valid Event Name");


# SUB style matcher
$router->event_route('message' => sub {
    my $args = shift;    
    if ($args->{username} eq 'taro') {
        return +{
            broker => q{broker02},     
            queue  => q{taro_queue},
        };
    } else {
        return +{
            broker => q{broker03},     
            queue  => q{other_queue},
        };
    }
});


my $sasl_result = $router->match(Ocean::Constants::EventType::SASL_AUTH_REQUEST);
ok($sasl_result, "Matched SASL result");
is($sasl_result->{broker}, q{broker01}, "Match Result BrokerName");
is($sasl_result->{queue}, q{hoge_queue}, "Match Result Queue");

my $message_result1 = $router->match(
    Ocean::Constants::EventType::SEND_MESSAGE
    , {
    username => q{taro}, 
});
ok($message_result1);
is($message_result1->{broker}, q{broker02});
is($message_result1->{queue}, q{taro_queue});

my $message_result2 = $router->match(
    Ocean::Constants::EventType::SEND_MESSAGE
    ,{
    username => q{jiro}, 
});
ok($message_result2);
is($message_result2->{broker}, q{broker03});
is($message_result2->{queue}, q{other_queue});

# MULTIPLE EVENTS
$router->event_route([qw(presence initial_presence unavailable_presence)] => {
    broker => q{broker04},     
    queue  => q{presence_queue},
});

my $presence_result1 = $router->match(
    Ocean::Constants::EventType::BROADCAST_PRESENCE,
    { username => q{saburo} }
);
ok($presence_result1);
is($presence_result1->{broker}, q{broker04});
is($presence_result1->{queue}, q{presence_queue});
my $presence_result2 = $router->match(
    Ocean::Constants::EventType::BROADCAST_INITIAL_PRESENCE,
    { username => q{saburo} }
);
ok($presence_result2);
is($presence_result2->{broker}, q{broker04});
is($presence_result2->{queue}, q{presence_queue});
my $presence_result3 = $router->match(
    Ocean::Constants::EventType::BROADCAST_UNAVAILABLE_PRESENCE,
    { username => q{saburo} }
);
ok($presence_result3);
is($presence_result3->{broker}, q{broker04});
is($presence_result3->{queue}, q{presence_queue});

# NON-REGISTERED EVENT
my $roster_result1 = $router->match(
    Ocean::Constants::EventType::ROSTER_REQUEST,
    { username => q{saburo} }
);

ok(!$roster_result1);

# NON-REGISTERED IF DEFAULT EXISTS
$router->default_route({
    broker => q{broker06},
    queue  => q{roster_queue},
});

my $roster_result2 = $router->match(
    Ocean::Constants::EventType::ROSTER_REQUEST,
    { username => q{saburo} }
);

ok($roster_result2);
is($roster_result2->{broker}, q{broker06});
is($roster_result2->{queue}, q{roster_queue});

# FROM FILE
my $filepath = q{t/data/route.pl};
my $router2 = Ocean::Cluster::Frontend::RouterEvaluator->evaluate($filepath);

my $message_result3 = $router2->match(Ocean::Constants::EventType::SEND_MESSAGE);
ok($message_result3);
is($message_result3->{broker}, q{broker01});
is($message_result3->{queue}, q{message_queue});

my $presence_result4 = $router2->match(Ocean::Constants::EventType::BROADCAST_PRESENCE);
is($presence_result4->{broker}, 'broker02');
is($presence_result4->{queue}, 'presence_queue');
my $presence_result5 = $router2->match(Ocean::Constants::EventType::BROADCAST_INITIAL_PRESENCE);
is($presence_result5->{broker}, 'broker02');
is($presence_result5->{queue}, 'presence_queue');
my $presence_result6 = $router2->match(Ocean::Constants::EventType::BROADCAST_UNAVAILABLE_PRESENCE);
is($presence_result6->{broker}, 'broker02');
is($presence_result6->{queue}, 'presence_queue');

my $vcard_result1 = $router2->match(Ocean::Constants::EventType::VCARD_REQUEST);
is($vcard_result1->{broker}, q{broker03});
is($vcard_result1->{queue}, q{default_queue});

done_testing();
