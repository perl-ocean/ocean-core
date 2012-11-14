use strict;
use warnings;

use Test::More;
use Log::Minimal;

use MIME::Base64 qw(encode_base64);

use Ocean::Config;
use Ocean::Config::Schema;
use Ocean::LoggerFactory;
use Ocean::Server;
use Ocean::ServerComponent::Listener::Stub;
use Ocean::CommonComponent::Timer::Stub;
use Ocean::ServerComponent::Daemonizer::Null;
use Ocean::CommonComponent::SignalHandler::Stub;
use Ocean::StreamFactory::Default;
use Ocean::StreamManager::Default;
use Ocean::Util::SASL::PLAIN qw(build_sasl_plain_b64);
use Ocean::Util::SASL::X_OAUTH2 qw(build_sasl_x_oauth2_b64);

use Ocean::EventDispatcher;
use Ocean::Standalone::Handler::Node;
use Ocean::Standalone::Handler::Authen;
use Ocean::Standalone::Handler::Connection;
use Ocean::Standalone::Handler::Message;
use Ocean::Standalone::Handler::People;

use Ocean::Standalone::Context;

my $context = Ocean::Standalone::Context->new;
my $event_dispatcher = Ocean::EventDispatcher->new;
$event_dispatcher->register_handler(node       => Ocean::Standalone::Handler::Node->new      );
$event_dispatcher->register_handler(authen     => Ocean::Standalone::Handler::Authen->new    );
$event_dispatcher->register_handler(message    => Ocean::Standalone::Handler::Message->new   );
$event_dispatcher->register_handler(connection => Ocean::Standalone::Handler::Connection->new);
$event_dispatcher->register_handler(people     => Ocean::Standalone::Handler::People->new    );

Ocean::Config->initialize(
    path   => q{t/data/config/example.yml},
    schema => Ocean::Config::Schema->config,
);

my $config = Ocean::Config->instance;


#local $Log::Minimal::LOG_LEVEL = 'MUTE';
local $Log::Minimal::LOG_LEVEL = 'DEBUG';

# Log::Minimal Debug Setting
local $ENV{LM_DEBUG} = 1 
    if $Log::Minimal::LOG_LEVEL eq 'DEBUG';

my $logger = Ocean::LoggerFactory->create($config);
$logger->initialize();
local $Log::Minimal::PRINT = sub { $logger->print(@_) };

my $listener = Ocean::ServerComponent::Listener::Stub->new(
    host            => $config->get(server => q{host}),
    port            => $config->get(server => q{port}),
    backlog         => $config->get(server => q{backlog}),
    max_read_buffer => $config->get(server => q{max_read_buffer}),
    timeout         => $config->get(server => q{timeout}),
);

my $builder         = Ocean::StreamFactory::Default->new;
my $stream_manager  = Ocean::StreamManager::Default->new;
my $daemonizer      = Ocean::ServerComponent::Daemonizer::Null->new;
my $signal_handler  = Ocean::CommonComponent::SignalHandler::Stub->new;
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

sub connection_starttls {
    my $socket = shift;
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});
    $socket->emulate_client_write(q{<starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>});
    $socket->emulate_client_starttls(1);
}

sub connection_authenticate {
    my ($socket, $username, $password) = @_;
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});
    $socket->emulate_client_write(
        sprintf(
            q{<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='PLAIN'>%s</auth>}, 
            build_sasl_plain_b64($username, $password),
        )
    );
}

sub connection_authenticate_oauth2 {
    my ($socket, $username, $token) = @_;
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});
    $socket->emulate_client_write(
        sprintf(
            q{<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='X-OAUTH2'>%s</auth>},
            build_sasl_x_oauth2_b64($username, $token),
        )
    );
}

sub connection_bind {
    my $socket = shift;
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});
    $socket->emulate_client_write(q{<iq type='set' id='bind_2'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'><resource>someresource</resource></bind></iq>});
    $socket->emulate_client_write(q{<iq to='example.com' type='set' id='sess_1'><session xmlns='urn:ietf:params:xml:ns:xmpp-session'/></iq>});
}

sub establish_authenticated_connection {
    my ($socket, $username, $password) = @_;
    &connection_starttls($socket);
    &connection_authenticate($socket, $username, $password);
}

sub establish_authenticated_connection_oauth2 {
    my ($socket, $username, $token) = @_;
    &connection_starttls($socket);
    &connection_authenticate_oauth2($socket, $username, $token);
}

sub establish_bound_connection {
    my ($socket, $username, $password) = @_;
    &establish_authenticated_connection($socket, $username, $password);
    &connection_bind($socket);
}

sub establish_available_connection {
    my ($socket, $username, $password) = @_;
    &establish_bound_connection($socket, $username, $password);
    $socket->emulate_client_write(q{<presence />});
}

my $client_oauth_1 = $listener->emulate_accept(q{dummy_id_oauth_1});
my @client_oauth_1_events;
$client_oauth_1->client_on_read(sub { push(@client_oauth_1_events, $_[0]) });
&establish_authenticated_connection_oauth2($client_oauth_1, 'taro', 'tarotarotaro');
is($client_oauth_1_events[$#client_oauth_1_events], '<success xmlns="urn:ietf:params:xml:ns:xmpp-sasl" />');
$client_oauth_1->close();

my $client_oauth_2 = $listener->emulate_accept(q{dummy_id_oauth_2});
my @client_oauth_2_events;
$client_oauth_2->client_on_read(sub { push(@client_oauth_2_events, $_[0]) });
&establish_authenticated_connection_oauth2($client_oauth_2, 'taro', 'invalid_token');
is($client_oauth_2_events[$#client_oauth_2_events], '<failure xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><not-authorized /></failure>');
$client_oauth_2->close();

my $client1 = $listener->emulate_accept(q{dummy_id_1});
my @client1_events;
$client1->client_on_read(sub { push(@client1_events, $_[0]) });
&establish_authenticated_connection($client1, 'taro', 'invalid');
is($client1_events[$#client1_events], '<failure xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><not-authorized /></failure>');
$client1->close();

my $client2 = $listener->emulate_accept(q{dummy_id_2});
my @client2_events;
$client2->client_on_read(sub { push(@client2_events, $_[0]) });
&establish_authenticated_connection($client2, 'taro', 'tarotaro');
is($client2_events[$#client2_events], '<success xmlns="urn:ietf:params:xml:ns:xmpp-sasl" />');
$client2->close();

my $client3 = $listener->emulate_accept(q{dummy_id_3});
my @client3_events;
$client3->client_on_read(sub { push(@client3_events, $_[0]) });
&establish_bound_connection($client3, 'taro', 'tarotaro');
like($client3_events[$#client3_events - 1], qr{<iq from\=\"xmpp\.example\.org\" id\=\"bind_2\" type=\"result\"><bind xmlns\=\"urn\:ietf\:params\:xml\:ns\:xmpp\-bind\"><jid>taro\@xmpp\.example\.org\/[a-zA-Z0-9]+<\/jid><\/bind><\/iq>});
is($client3_events[$#client3_events], '<iq from="xmpp.example.org" id="sess_1" type="result"><session xmlns="urn:ietf:params:xml:ns:xmpp-session" /></iq>');
$client3->close();

my $client4 = $listener->emulate_accept(q{dummy_id_4});
my @client4_events;
$client4->client_on_read(sub { push(@client4_events, $_[0]) });
&establish_available_connection($client4, 'taro', 'tarotaro');

my $client5 = $listener->emulate_accept(q{dummy_id_5});
my @client5_events;
$client5->client_on_read(sub { push(@client5_events, $_[0]) });
&establish_available_connection($client5, 'jiro', 'jirojiro');

like($client4_events[$#client4_events], qr{<presence from="jiro\@xmpp.example.org/[a-zA-Z0-9]+" to="taro\@xmpp.example.org/[a-zA-Z0-9]+"><show>chat</show><priority>0</priority><x xmlns="vcard-temp:x:update"><photo>f451ed7c60b4aaa309dbbdb475b65ce5e2f710e0</photo></x></presence>});
like($client5_events[$#client5_events], qr{<presence from="taro\@xmpp.example.org/[a-zA-Z0-9]+" to="jiro\@xmpp.example.org/[a-zA-Z0-9]+"><show>chat</show><priority>0</priority><x xmlns="vcard-temp:x:update"><photo>f7d470cac763de33d421e8b03f44706b0e906872</photo></x></presence>});

$client4->emulate_client_write('<iq id="roster_1" type="get"><query xmlns="jabber:iq:roster" /></iq>');

like($client4_events[$#client4_events], qr{<iq to="taro\@xmpp.example.org/[a-zA-Z0-9]+" from="taro\@xmpp.example.org" id="roster_1" type="result"><query xmlns="jabber:iq:roster"><item jid="jiro\@xmpp.example.org" subscription="both" name="Jiro"/><item jid="saburo\@xmpp.example.org" subscription="from" name="Saburo"/><item jid="shiro\@xmpp.example.org" subscription="from" name="Shiro"/></query></iq>});

$client5->emulate_client_write('<iq id="roster_1" type="get"><query xmlns="jabber:iq:roster" /></iq>');
like($client5_events[$#client5_events], qr{<iq to="jiro\@xmpp.example.org/[a-zA-Z0-9]+" from="jiro\@xmpp.example.org" id="roster_1" type="result"><query xmlns="jabber:iq:roster"><item jid="taro\@xmpp.example.org" subscription="both" name="Taro"/><item jid="saburo\@xmpp.example.org" subscription="from" name="Saburo"/></query></iq>});

$client5->emulate_client_write('<iq id="vcard_1" to="jiro@xmpp.example.org" type="get"><vCard xmlns="vcard-temp" /></iq>');
my $vcard_packet = qr{<iq to="jiro\@xmpp.example.org/[a-zA-Z0-9]+" from="jiro\@xmpp.example.org" id="vcard_1" type="result"><vCard xmlns="vcard-temp"><FN>Jiro</FN><PHOTO><TYPE>image/jpeg</TYPE><BINVAL>/9j/4AAQSkZJRgABAQAAAQABAAD//gA7Q1JFQVRPUjogZ2QtanBlZyB2MS4wICh1c2luZyBJSkcg
SlBFRyB2NjIpLCBxdWFsaXR5ID0gODUK/9sAQwAFAwQEBAMFBAQEBQUFBgcMCAcHBwcPCwsJDBEP
EhIRDxERExYcFxMUGhURERghGBodHR8fHxMXIiQiHiQcHh8e/9sAQwEFBQUHBgcOCAgOHhQRFB4e
Hh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4e/8AAEQgAVgCC
AwEiAAIRAQMRAf/EAB8AAAEFAQEBAQEBAAAAAAAAAAABAgMEBQYHCAkKC//EALUQAAIBAwMCBAMF
BQQEAAABfQECAwAEEQUSITFBBhNRYQcicRQygZGhCCNCscEVUtHwJDNicoIJChYXGBkaJSYnKCkq
NDU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6g4SFhoeIiYqSk5SVlpeYmZqi
o6Slpqeoqaqys7S1tre4ubrCw8TFxsfIycrS09TV1tfY2drh4uPk5ebn6Onq8fLz9PX29/j5\+v/E
AB8BAAMBAQEBAQEBAQEAAAAAAAABAgMEBQYHCAkKC//EALURAAIBAgQEAwQHBQQEAAECdwABAgMR
BAUhMQYSQVEHYXETIjKBCBRCkaGxwQkjM1LwFWJy0QoWJDThJfEXGBkaJicoKSo1Njc4OTpDREVG
R0hJSlNUVVZXWFlaY2RlZmdoaWpzdHV2d3h5eoKDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKz
tLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uLj5OXm5\+jp6vLz9PX29/j5\+v/aAAwDAQACEQMRAD8A
veBE/wBAj/3a7S3T5D9K4zwWSlimfQV2FrNxivKhiadrXN5QdzifiFFI9pIqRljivNvDGi6nPr8c
7wlUXjmvebyxS7PzKCDUmn6JawuGCKKG41HoxWsi34UgaKzQMOQKj8Vti3b6Vs2wjjTavFYPi582
7gelOvpTZVJe8cDppzqDn/ars7IfIK4vSFb7a5II\+au1sf8AVivy/F39qz2baFoCjFOFGK5LhYYa
YwqQimmi5VivIKoXxxG1aUg61l6kcRNVR3BIs\+GUy4PvW/rzbNPb6Vl\+F4\+F4q94ufZp7fSv1TLI
cmGivI8qa5qx5dPdHz5Of4j/ADorEuLofaJOf4z/ADorXnPo1g1bY7vQAILZVPpXQW8qEVzlvuUC
rsMrCvmFWZ4PIjo45E45q5Dg/wAVc3HdMOtXra8Pc134KsnOxlUhodBGhxw1cH41m1fTb0yPMZ7R
zlflHHsa6garDEvzuPpmsDxJq9ne272r4KuMAk9D2r0sZOm6duazLwcJxndxujBs9UST54YUO0ZY
pzj6g81pW2tmTJRNqp1JHWvN0ublNSkaJ1tmtn2uxBGfp61rXGpM1hlZGA3bfQngYrwHSi3drU9h
xj0R2v8AbZEe7dgHOCe9SWGtOzurlQqrkk9fpXG2\+pi3MMMoEiqS59CCDjmsTVfGcjSy2rKba3BI
ZolGWOeAT9Kv2CqKzSZNlc9Cm8Y2kMxSWSMAHBA7V0VtdQXNvHPFIrI4yCDXy5q2pS3GvxW9vKTG
TkFU5HsQa6HWfiTP4b1W30kREwxQpvIOcE8/1rkr5Iq0bUo\+9a5FedOnFSPoOUjBrI1M/KB6mud8
MeNbXVLFJBIDuGetX59VguJo0VgSTXzkcLUhVUJLqSpJq6O08LphFqv4\+m8vT35/hq94aGIQfas/
xzZyXlnIiZyRX6nh48tFLyPMp2dZNnz/AHN8ftEnP8Z/nRWtL4KvWldtzcsT0orD2c\+x9ssThrfE
ejR9KsR1TiJqLVNSj06IbyPMYcD096\+bVGbdmj5GK5nZF3UL\+3sIt0zZbHCDqa5PUPFN\+7ssUEkK
Z4IAOfyNZ01/PeXpkTHl55d2x\+VOaeEs0WAWYdd3NdKpxgtDthTjEq3Wt6iQzu8pQct7VjTa5K8p
ZXfCcnnNWNQhkWYfaCWRuN46D6\+lYF6726sNyOUbHHPBq4RTNHKx6zYWtr4gs7bUtqN\+7DOvQk5w
TXP\+JbJrB9kThhJLlcduQCPyx\+tcr4O1svpV/o09w0HngeTcIcGP2zW/oemXVppX2S4uvtjrtaFs
sxIHUkn3AqpwUdeplFu/kW4NNuLqQu0oSOSMsoPBVRwBWH4g8INDb\+esysW6rmovEC6xPHbw6NqL
QXMQcyqX2nrxjPHHoanWe4fTfK1O6kmv3IK\+W/CADnkccn0odowvcFzOVrGJonhyNtUhaYyI6ODg
GuE\+KF1a3fjjUZbP/VCTaPcgYr6H\+GXgi61\+5ee/NzbWKoQryJhpG6fKf61neLv2ZfOne40PWnXc
xYrOu79eK7MvqKEnKbOPHpzSjE8w8BxagunL5OSpGRXceF2v31iJJwwAPWuj8OeAdU8PWv2W\+tiy
xjAkUcGr8NhHb3AkCgEGtK0Kc5c1tTKEWo2uem\+G9q2S5YdKvXMccow2DXFWGsCCILuqy3iAf3q6
4VklYxlB3ujfOnW/90flRWB/b6/3/wBaK19tELSOPs70GU5YFUGetc5q\+ord3skkjZBbA54xXYeJ
/B2p6XY3EunxNdRhfm8vlgO/HU/hXm4hnjuTHdRSW8obG2QEFfz715\+OrKrUvHY7sFTUKeu5pxF4
5R5gAQjIAGAPqTVhbF3cSWwJzyCORn0qO2RXAhuiAv8ACa2LC1Mbh7e43J7mvMmmdt7FC4tWMZed
TE\+MEMODXK\+I7KaYNIqBGCEFFUjePUHvXok1xLHMIriQsCOuMcfjWXfxRLNsiJ2v/Dnv7elEZWZO
rPF45pfPaFy42ns2OM16r4d8R2jaTEwU/bbePyfL3jMi/wB4E9fpXF\+PdHEDSXMCfMjbnKjHBrN0
qNzGrnO31PSumo1KN0TTVnqd7aRAST3k\+E81i2H/AIB707wxJFf6p5dpGPLB5kI5PPrXMM01wgik
nd1H8O7IrodH1OLQtPknYAlV\+VRySa4kuZ2Np6Js968I63aw6aLV3CmH5Riuis79LmMeQ4ck\+tfO
vhnxMJTtEhaaU/Kg6kmvWPCzTWgE9xOEJTIj9PWunnT3OOVOx6EY1aPbMAwPYiue1nw1p92C0SiK
Q9CO9Vl1m5uEHkyKN/3SRzirFsZhg3FzIJDyB/SqjWfQzdPuczJ4Nv8APDw47c0sXhGSEmS7Hmhe
ioetdNNqPlSlFRmbA3MxwopkutQIM7gQOC4BOD\+FbRxGupHK1rY502lspx/ZsnHHSitwanIRlWQq
eh9f0orb6wuxftP7poROCfMjRQGHGG5\+p7VT1vRtM1m38nULRJ1PIduGB9iOR\+FVVvLLLNNO0Uz8
CMEq2PTA61aFyIcbC8oJyIww3kY7AmuHnHynIXXwv8iTzNKvi0ZJPlXPOBjsQP5\+tZt14T1vTmjk
tbNrrPeL5gD/AJ79K9FtZlvSbkrNGo4yxZWB9CBjFXImkYny0AReMbs/ypNqXQtSkjxy/lkt1C6l
ZTQSPkKJVK5I6nmsed0lOw4AH3WHavfLqysryARX9tBcRjD7ZUBAIPpiuX1rwL4cuo5pYopbItjB
hf5QfZelRKnfqXGqlujw7xMn2iC4hl/1giJB7MMciuU0yHzIwsUcsxA4ycLXpvjrwhq\+lp50Ucl7
aqCC6J86D/aArzDSr\+SAFIpoAAcHeCSKqMJcjNVNNqxraZp2ozXKCWzCqD/C2K14bOzTzBPHhweS
2SP8Kb4enuZrgMkzzEsO2F\+gHetfV4FF5EyK7\+YRvjxn26VChoxylqa3heGwtkE0flxNuyDGu5h\+
FdbFIb5la0W4BT77yEqpH4fyrldJt43uYVMSxKrkEoNrEehNddHGWURb/IT\+FA/Xv8xwc55qeVvc
iTS2Nq0i2xBIipwcuyjr/Sras/LEM6qTzgk/hWV88iqryk4BDpAuOPTNWGDRRLDkybm2h3B\+br8u
BinzakOIXjfZVN35vmyscpFuwPwGa53UdYvoIvO8yMOT98vhVH05rXkhbTo1dmuLzgjDMCFOOuOq
188fF7x3a3F7c6ZpaNbSxEEzRSfKr8Eg44PcV10KEqsrI56tVQV2eiTeNtUErhZNFcBjhvPYZ96K
\+XGaBmLMs7knJYsefeivW/s3\+8cX1vyPu5LqeCJpppmlRVJkwoVifY\+lW9Olku4vPjC28IGQEHzN
9aKK8LrY9B7GhaxwvKAxmAHAAfr7mrtm29coEWNeEXZ0/WiiqIuSzbmYpxlsdRxVVTFLKy7ANuV4
GP680UUuoX0GsIZ90QiURx8vkfernp/hf4JvLkag\+kLFLKdxETsiknuVBwfyoorSEmTJ22NjRPCX
h/Sdg0/Too2j4DsCz/8AfROamvbfThMd9pGZF53eWpOfqaKKG2G71KpggILrEhBxwVAqC4s7ORWS
a3Xag4KEg5P8qKKzluWth1vp0avttZpE2DGHwR/jSR2E8dws0n2fz0z88alc5zn\+n60UU1FaBzMW
SC4kU\+b5LKeNvseeeOa\+X/2gPh3pnhy/bxFp91KYb66YPaOvEbnLEqc9M9qKK9DAScaiS6nLiVeJ
5UJP9px9DRRRX0B5x//Z</BINVAL></PHOTO></vCard></iq>};
like($client5_events[$#client5_events], $vcard_packet);

my $client6 = $listener->emulate_accept(q{dummy_id_6});
my @client6_events;
$client6->client_on_read(sub { push(@client6_events, $_[0]) });
&establish_available_connection($client6, 'taro', 'tarotaro');

like($client5_events[$#client5_events], qr{<presence from="taro\@xmpp.example.org/[a-zA-Z0-9]+" to="jiro\@xmpp.example.org/[a-zA-Z0-9]+"><show>chat</show><priority>0</priority><x xmlns="vcard-temp:x:update"><photo>f7d470cac763de33d421e8b03f44706b0e906872</photo></x></presence>});
like($client6_events[$#client6_events], qr{<presence from="jiro\@xmpp.example.org/[a-zA-Z0-9]+" to="taro\@xmpp.example.org/[a-zA-Z0-9]+"><show>chat</show><priority>0</priority><x xmlns="vcard-temp:x:update"><photo>f451ed7c60b4aaa309dbbdb475b65ce5e2f710e0</photo></x></presence>});

$client5->emulate_client_write(q{<message type="chat" to="taro@xmpp.example.org"><body>foobar</body></message>});
like($client4_events[$#client4_events], qr{<message type="chat" from="jiro\@xmpp\.example\.org/[a-zA-Z0-9]+" to="taro\@xmpp.example.org/[a-zA-Z0-9]+"><body>foobar</body></message>});
like($client6_events[$#client6_events], qr{<message type="chat" from="jiro\@xmpp\.example\.org/[a-zA-Z0-9]+" to="taro\@xmpp.example.org/[a-zA-Z0-9]+"><body>foobar</body></message>});

$client5->close();
like($client4_events[$#client4_events], qr{<presence from="jiro\@xmpp.example.org/[a-zA-Z0-9]+" to="taro\@xmpp.example.org/[a-zA-Z0-9]+" type="unavailable" />});
like($client6_events[$#client6_events], qr{<presence from="jiro\@xmpp.example.org/[a-zA-Z0-9]+" to="taro\@xmpp.example.org/[a-zA-Z0-9]+" type="unavailable" />});

$server->shutdown();
is($client4_events[$#client4_events - 1], '<stream:error><system-shutdown xmlns="urn:ietf:params:xml:ns:xmpp-streams" /></stream:error>');
is($client6_events[$#client6_events - 1], '<stream:error><system-shutdown xmlns="urn:ietf:params:xml:ns:xmpp-streams" /></stream:error>');

done_testing;
