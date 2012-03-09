use strict;
use Test::More;

use Log::Minimal;
use Try::Tiny;

use Ocean::StreamComponent::IO::Decoder::Default;
use Ocean::Test::Spy::StreamComponent::IO;
use Ocean::Config;
use Ocean::Config::Schema;

Ocean::Config->initialize(
    path   => q{t/data/config/example.yml},
    schema => Ocean::Config::Schema->config,
);

local $Log::Minimal::LOG_LEVEL = 'MUTE';
#local $Log::Minimal::LOG_LEVEL = 'DEBUG';

# Log::Minimal Debug Setting
local $ENV{LM_DEBUG} = 1 
    if $Log::Minimal::LOG_LEVEL eq 'DEBUG';

my $decoder = Ocean::StreamComponent::IO::Decoder::Default->new;
my $delegate = Ocean::Test::Spy::StreamComponent::IO->new;
$decoder->set_delegate( $delegate );

TEST_INVALID_ROOT: {

    $decoder->feed(q{<?xml version="1.0" encoding="UTF-8"?>});
    $decoder->feed(q{<stream:notstream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="example.com" version="1.0">});
    ok($delegate->{error});
    ok($delegate->{error}->isa('Ocean::Error::ProtocolError'));
    $delegate->clear();

    $decoder->release();
    $decoder = Ocean::StreamComponent::IO::Decoder::Default->new;
    $decoder->set_delegate( $delegate );

    $decoder->feed(q{<?xml version="1.0" encoding="UTF-8"?>});
    $decoder->feed(q{<stream:stream xmlns:stream="http://etherx.jabber.org/notstreams" xmlns="jabber:client" to="example.com" version="1.0">});
    ok($delegate->{error});
    ok($delegate->{error}->isa('Ocean::Error::ProtocolError'));
    $delegate->clear();
}

TEST_STREAM: {

    $decoder->release();
    $decoder = Ocean::StreamComponent::IO::Decoder::Default->new;
    $decoder->set_delegate( $delegate );

    $decoder->feed(q{<?xml version="1.0" encoding="UTF-8"?>});
    $decoder->feed(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="example.com" version="1.0">});

    is($delegate->{stream_attrs}{to}, 'example.com');
    is($delegate->{stream_attrs}{version}, '1.0');

    is($decoder->depth(), 1);
    #ok(!$decoder->is_on_end_of_element(1));
}

TEST_XML_ELEMENT_DEPTH: {

    $decoder->feed(q{<message to="user2@example.org/work" type="chat">});

    is($decoder->depth(), 2);
    #ok(!$decoder->is_on_end_of_element(1));

    $decoder->feed(q{<body>});
    is($decoder->depth(), 3);
    #ok(!$decoder->is_on_end_of_element(3));
    $decoder->feed(q{Hoge});
    $decoder->feed(q{</body>});
    is($decoder->depth(), 2);
    #ok($decoder->is_on_end_of_element(2));
    $decoder->feed(q{</message>});
    is($decoder->depth(), 1);
    #ok($decoder->is_on_end_of_element(1));
    $delegate->clear();
}

TEST_SEPARATED_PACKETS: {

    ok(!$delegate->{message});
    $decoder->feed(q{<message to="user2@});
    $decoder->feed(q{xmpp.example.org/work" type="});
    $decoder->feed(q{chat"><subject>});
    $decoder->feed(q{mysubject</subject><body>Hoge</body></message>});
    is($delegate->{message_to_jid}->as_string, 'user2@xmpp.example.org/work');
    is($delegate->{message}->body, 'Hoge');
    is($delegate->{message}->thread, '');
    $delegate->clear();
}

TEST_MESSAGE: {

    sub verify_message_ok {
        my (%args) = @_;
        $decoder->feed($args{packet});
        $args{message} ||= '';
        ok($delegate->{message_to_jid}, $args{message});
        is($delegate->{message_to_jid}->as_string, $args{to_jid}, $args{message});
        is($delegate->{message}->body,    $args{body},    $args{message});
        is($delegate->{message}->thread,  $args{thread},  $args{message});
        $delegate->clear();
    }

    &verify_message_ok(
        packet  => q{<message to="user2@xmpp.example.org/work" type="chat"><subject>mysubject</subject><body>Hoge</body></message>},
        to_jid  => 'user2@xmpp.example.org/work',
        type    => 'chat',
        subject => 'mysubject',
        thread  => '',
        body    => 'Hoge',
        message => 'correct message',
    );

    sub verify_message_not_ok {
        my (%args) = @_;
        $delegate->{message} = undef;
        $decoder->feed($args{packet});
        ok(!$delegate->{message}, $args{message});
        $delegate->clear();
    }

    &verify_message_not_ok(
        packet  => q{<message type="chat"><subject>mysubject</subject><body>Hoge</body></message>},
        message => 'no message@to',
    );

    &verify_message_not_ok(
        packet  => q{<message to="_invalid_" type="chat"><subject>mysubject</subject><body>Hoge</body></message>},
        message => 'invalid message@to',
    );
}

TEST_PRESENCE: {

    sub verify_presence_ok {
        my (%args) = @_;
        $args{message} ||= '';
        $decoder->feed($args{packet});
        is($delegate->{presence}->show, $args{show}, $args{message});
        is($delegate->{presence}->status, $args{status}, $args{message});
        is($delegate->{presence}->priority, 0, $args{message});
        $delegate->clear();
    }

    sub verify_presence_not_ok {
        my (%args) = @_;
        $args{message} ||= '';
        $decoder->feed($args{packet});
        ok($delegate->{error}, $args{message});
        like($delegate->{error}->message, qr/$args{errmsg}/, $args{message});
        $delegate->clear();
    }

    # empty packet
    &verify_presence_ok(
        packet     => '<presence></presence>',
        show       => 'chat',
        status     => '',
        priority   => 0,
        image_hash => '',
        message    => q{'chat' and 'available' set by defualt},
    );

    # empty packet with @type="available"
    &verify_presence_ok(
        packet     => '<presence type="available"></presence>',
        show       => 'chat',
        status     => '',
        priority   => 0,
        image_hash => '',
        message    => q{'chat' set by default},
    );

    # check show
    &verify_presence_ok(
        packet     => '<presence><show>dnd</show></presence>',
        show       => 'dnd',
        status     => '',
        priority   => 0,
        image_hash => '',
        message    => 'dnd show-type'
    );

    &verify_presence_ok(
        packet     => '<presence><show>away</show></presence>',
        show       => 'away',
        status     => '',
        priority   => 0,
        image_hash => '',
        message    => 'away show-type'
    );

    &verify_presence_ok(
        packet     => '<presence><show>xa</show></presence>',
        show       => 'xa',
        status     => '',
        priority   => 0,
        image_hash => '',
        message    => 'xa show-type'
    );

    &verify_presence_ok(
        packet     => '<presence><show>xa</show><status>foobar</status></presence>',
        show       => 'xa',
        status     => 'foobar',
        priority   => 0,
        image_hash => '',
        message    => 'status is ok'
    );

    &verify_presence_ok(
        packet     => '<presence><show>xa</show><status>foobar</status><priority>10</priority></presence>',
        show       => 'xa',
        status     => 'foobar',
        priority   => 10,
        image_hash => '',
        message    => 'in-range priority'
    );

    &verify_presence_ok(
        packet     => '<presence><show>xa</show><status>foobar</status><priority>-127</priority></presence>',
        show       => 'xa',
        status     => 'foobar',
        priority   => -127,
        image_hash => '',
        message    => 'minimum priority'
    );

    &verify_presence_ok(
        packet     => '<presence><show>xa</show><status>foobar</status><priority>128</priority></presence>',
        show       => 'xa',
        status     => 'foobar',
        priority   => 128,
        image_hash => '',
        message    => 'maximum priority'
    );

    # ignore invalid priority ( set 0 by default )
    &verify_presence_ok(
        packet     => '<presence><show>xa</show><status>foobar</status><priority>-128</priority></presence>',
        show       => 'xa',
        status     => 'foobar',
        priority   => 0,
        image_hash => '',
        message    => 'under minimum priority'
    );

    &verify_presence_ok(
        packet     => '<presence><show>xa</show><status>foobar</status><priority>129</priority></presence>',
        show       => 'xa',
        status     => 'foobar',
        priority   =>  0,
        image_hash => '',
        message    => 'over maximum priority'
    );

    &verify_presence_ok(
        packet     => '<presence><show>xa</show><status>foobar</status><priority>129</priority><x xmlns="vcard-temp:x:update"><photo>XXXXXX</photo></x></presence>',
        show       => 'xa',
        status     => 'foobar',
        priority   =>  0,
        image_hash => 'XXXXXX',
        message    => 'correct image-hash'
    );

    &verify_presence_ok(
        packet     => '<presence><show>xa</show><status>foobar</status><priority>129</priority><x xmlns="vcard-temp:x:update"></x></presence>',
        show       => 'xa',
        status     => 'foobar',
        priority   =>  0,
        image_hash => '',
        message    => 'ignore incompleted image-hash'
    );

    ## unknown show
    &verify_presence_not_ok(
        packet  => '<presence><show>unknown</show></presence>',
        errmsg  => q{unsupported presence@show 'unknown'},
        message => q{unknown show-type should throw exception},
    );

}

TEST_IGNORED_PRESENSES: {

    sub verify_ignored_presence {
        my (%args) = @_;
        $decoder->feed($args{packet});
        ok(!$delegate->{error}, "ignored presence");
        ok(!$delegate->{presence}, "ignored presence");
        $delegate->clear();
    }

    &verify_ignored_presence(
        packet => sprintf('<presence type="%s"></presence>', $_),
    ) for qw(subscribe unsubscribe subscribed unsubscribed probe error unknown_type);
}

TEST_UNAVAILABLE_PRESENCE: {
    ok(!$delegate->{unavailable_presence}, "unavailable presence");
    $decoder->feed("<presence type='unavailable'></presence>");
    ok(!$delegate->{error}, "unavailable presence");
    ok($delegate->{unavailable_presence}, "unavailable presence");
    $delegate->clear();
}

TEST_BIND_REQUEST: {

    # WITHOUT RESOURCE
    $decoder->feed(q{<iq id="my_bind_id" type="set"><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind" /></iq>});
    ok($delegate->{bind_request}, "bind request");
    is($delegate->{bind_request}->id, 'my_bind_id', "bind request");
    ok(!$delegate->{bind_request}->resource, "bind request");
    $delegate->clear();

    # WITH RESOURCE
    $decoder->feed(q{<iq id="my_bind_id2" type="set"><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"><resource>someresource</resource></bind></iq>});
    ok($delegate->{bind_request});
    is($delegate->{bind_request}->id, 'my_bind_id2');
    #is($delegate->{bind_request}->resource, 'someresource');
    ok(!$delegate->{bind_request}->resource);
    $delegate->clear();
}

TEST_SESSION_REQUEST: {

    ok(!$delegate->{session_request});
    $decoder->feed(q{<iq id="my_session_id" type="set"><session xmlns="urn:ietf:params:xml:ns:xmpp-session"/></iq>});
    ok($delegate->{session_request});
    is($delegate->{session_request}->id, 'my_session_id');
    $delegate->clear();
}

TEST_ROSTER_REQUEST: {

    ok(!$delegate->{roster_request});
    $decoder->feed(q{<iq id="my_roster_id" type="get"><query xmlns="jabber:iq:roster" /></iq>});
    ok($delegate->{roster_request}, 'roster request not found');
    is($delegate->{roster_request}->id, q{my_roster_id}, 'roster reuqest id');
    $delegate->clear();
}

TEST_PING: {
    ok(!$delegate->{ping}, 'ping');
    $decoder->feed(q{<iq id="my_ping_id" type="get"><ping xmlns="urn:xmpp:ping" /></iq>});
    ok($delegate->{ping}, 'ping');
    is($delegate->{ping}->id, q{my_ping_id}, 'ping id');
    $delegate->clear();
}

TEST_VCARD_REQUEST: {
    ok(!$delegate->{vcard_request});

    # XXX allow element without 'to'?
    # $decoder->feed(q{<iq id="my_vcard_id" type="get"><vCard xmlns="vcard-temp"></vCard></iq>});

    $decoder->feed(q{<iq id="my_vcard_id" type="get" to="user2@xmpp.example.org"><vCard xmlns="vcard-temp"></vCard></iq>});
    ok($delegate->{vcard_request});
    is($delegate->{vcard_request}->to->as_string, q{user2@xmpp.example.org});
    is($delegate->{vcard_request}->id, q{my_vcard_id});
    $delegate->clear();
}

done_testing;
