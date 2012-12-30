use strict; 
use  Test::More;

use Log::Minimal;

local $Log::Minimal::PRINT = sub { };

use Ocean::Config;
use Ocean::Config::Schema;
use Ocean::StreamComponent::IO;
use Ocean::StreamComponent::IO::Encoder::Default;
use Ocean::StreamComponent::IO::Decoder::Default;
use Ocean::StreamComponent::IO::Socket::Stub;
use Ocean::Stanza::DeliveryRequest::BoundJID;
use Ocean::Stanza::DeliveryRequest::ChatMessage;
use Ocean::Stanza::DeliveryRequest::Presence;
use Ocean::Stanza::DeliveryRequest::vCard;
use Ocean::Stanza::DeliveryRequest::Roster;
use Ocean::Stanza::DeliveryRequest::RosterItem;
use Ocean::Stream;
use Ocean::JID;

use Ocean::Test::Spy::Server;

#use Log::Minimal;
#local $Log::Minimal::PRINT = sub { };

Ocean::Config->initialize(
    path   => q{t/data/config/example.yml},
    schema => Ocean::Config::Schema->config,
);
Ocean::Config->instance;

my ($delegate, $socket, @client_read_data, $stream, $io);

sub reset {
    $stream->release() if $stream;
    $delegate = Ocean::Test::Spy::Server->new;

    $socket = Ocean::StreamComponent::IO::Socket::Stub->new;
    @client_read_data = ();
    $socket->client_on_read(sub { my $data = shift; push(@client_read_data, $data) });


    $stream = Ocean::Stream->new(
        id => q{dummy_id},
        io => Ocean::StreamComponent::IO->new(
            encoder => Ocean::StreamComponent::IO::Encoder::Default->new,
            decoder => Ocean::StreamComponent::IO::Decoder::Default->new,
            socket  => $socket,
        ),
    );
    $stream->set_delegate($delegate);
}

TEST_INVALID_STREAM_SCHEME: {
    &reset();
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<invalid_xml:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});

    is($delegate->get_event(0)->{type}, 'unbound_closed');
}

TEST_INVALID_STANZA_SCHEME: {
    &reset();
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});

    like($client_read_data[0], qr{<\?xml version="1\.0"\?><stream\:stream from="xmpp\.example\.org" id="[0-9a-zA-Z]+" version="1\.0" xml\:lang=\"en\" xmlns:stream=\"http\:\/\/etherx\.jabber\.org\/streams\" xmlns=\"jabber\:client\">});
    is($client_read_data[1], q{<stream:features><starttls xmlns="urn:ietf:params:xml:ns:xmpp-tls" /></stream:features>});

    $socket->emulate_client_write(q{<hoge:hoge xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>});

    is($delegate->get_event(0)->{type}, 'unbound_closed');
    is($client_read_data[2], '<stream:error><invalid-xml xmlns="urn:ietf:params:xml:ns:xmpp-streams" /><text xmlns="urn:ietf:params:xml:ns:xmpp-streams">error</text></stream:error>');
    is($client_read_data[3], '</stream:stream>');
}

TEST_INVALID_TLS_SCENARIO: {
    &reset();
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});

    like($client_read_data[0], qr{<\?xml version="1\.0"\?><stream\:stream from="xmpp\.example\.org" id="[0-9a-zA-Z]+" version="1\.0" xml\:lang=\"en\" xmlns:stream=\"http\:\/\/etherx\.jabber\.org\/streams\" xmlns=\"jabber\:client\">});
    is($client_read_data[1], q{<stream:features><starttls xmlns="urn:ietf:params:xml:ns:xmpp-tls" /></stream:features>});

    $socket->emulate_client_write(q{<starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>});
    is($client_read_data[2], '<proceed xmlns="urn:ietf:params:xml:ns:xmpp-tls" />');

    $socket->emulate_client_starttls(0);

    is($delegate->get_event(0)->{type}, 'unbound_closed');
}

TEST_FAILED_SASL_SCENARIO_UNSUPPORTED_MECH: {
    &reset();
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});

    like($client_read_data[0], qr{<\?xml version="1\.0"\?><stream\:stream from="xmpp\.example\.org" id="[0-9a-zA-Z]+" version="1\.0" xml\:lang=\"en\" xmlns:stream=\"http\:\/\/etherx\.jabber\.org\/streams\" xmlns=\"jabber\:client\">});
    is($client_read_data[1], q{<stream:features><starttls xmlns="urn:ietf:params:xml:ns:xmpp-tls" /></stream:features>});

    $socket->emulate_client_write(q{<starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>});
    is($client_read_data[2], '<proceed xmlns="urn:ietf:params:xml:ns:xmpp-tls" />');

    $socket->emulate_client_starttls(1);
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});
    like($client_read_data[3], qr{<\?xml version="1\.0"\?><stream\:stream from="xmpp\.example\.org" id="[0-9a-zA-Z]+" version="1\.0" xml\:lang=\"en\" xmlns:stream=\"http\:\/\/etherx\.jabber\.org\/streams\" xmlns=\"jabber\:client\">});
    is($client_read_data[4], q{<stream:features><mechanisms xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><mechanism>PLAIN</mechanism><mechanism>X-OAUTH2</mechanism></mechanisms></stream:features>});

    $socket->emulate_client_write(q{<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='DIGEST-MD5'/>});

    is($client_read_data[5], '<failure xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><invalid-mechanism /></failure>');
}

TEST_FAILED_SASL_SCENARIO_INVALID_PASSWORD_AND_REAUTH: {
    &reset();
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});

    like($client_read_data[0], qr{<\?xml version="1\.0"\?><stream\:stream from="xmpp\.example\.org" id="[0-9a-zA-Z]+" version="1\.0" xml\:lang=\"en\" xmlns:stream=\"http\:\/\/etherx\.jabber\.org\/streams\" xmlns=\"jabber\:client\">});
    is($client_read_data[1], q{<stream:features><starttls xmlns="urn:ietf:params:xml:ns:xmpp-tls" /></stream:features>});

    $socket->emulate_client_write(q{<starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>});
    is($client_read_data[2], '<proceed xmlns="urn:ietf:params:xml:ns:xmpp-tls" />');

    $socket->emulate_client_starttls(1);
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});
    like($client_read_data[3], qr{<\?xml version="1\.0"\?><stream\:stream from="xmpp\.example\.org" id="[0-9a-zA-Z]+" version="1\.0" xml\:lang=\"en\" xmlns:stream=\"http\:\/\/etherx\.jabber\.org\/streams\" xmlns=\"jabber\:client\">});
    is($client_read_data[4], q{<stream:features><mechanisms xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><mechanism>PLAIN</mechanism><mechanism>X-OAUTH2</mechanism></mechanisms></stream:features>});

    # invalid pass
    $socket->emulate_client_write(q{<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='PLAIN'>INVALID_PASS</auth>});

    is($delegate->get_last_event->{type}, 'auth');
    is($delegate->get_last_event->{data}->{stream_id}, 'dummy_id');
    is($delegate->get_last_event->{data}->{auth}->mechanism, 'PLAIN');
    is($delegate->get_last_event->{data}->{auth}->text, 'INVALID_PASS');

    $stream->on_server_failed_sasl_auth();
    is($client_read_data[5], '<failure xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><not-authorized /></failure>');

    # retry
    $socket->emulate_client_write(q{<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='PLAIN'>VALID_PASS</auth>});

    is($delegate->get_last_event->{type}, 'auth');
    is($delegate->get_last_event->{data}->{stream_id}, 'dummy_id');
    is($delegate->get_last_event->{data}->{auth}->mechanism, 'PLAIN');
    is($delegate->get_last_event->{data}->{auth}->text, 'VALID_PASS');

    $stream->on_server_completed_sasl_auth(q{user2}, q{user2}, q{resource});
    is($client_read_data[6], '<success xmlns="urn:ietf:params:xml:ns:xmpp-sasl" />');
}

TEST_CORRECT_SCENARIO: {
    &reset();

    # =====================#
    # START STREAM
    # =====================#
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});

    like($client_read_data[0], qr{<\?xml version="1\.0"\?><stream\:stream from="xmpp\.example\.org" id="[0-9a-zA-Z]+" version="1\.0" xml\:lang=\"en\" xmlns:stream=\"http\:\/\/etherx\.jabber\.org\/streams\" xmlns=\"jabber\:client\">});
    is($client_read_data[1], q{<stream:features><starttls xmlns="urn:ietf:params:xml:ns:xmpp-tls" /></stream:features>});

    # =====================#
    # REQUIRE STARTTLS
    # =====================#
    $socket->emulate_client_write(q{<starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>});
    is($client_read_data[2], '<proceed xmlns="urn:ietf:params:xml:ns:xmpp-tls" />');

    # =====================#
    # TLS NEGOTIATION
    # =====================#
    $socket->emulate_client_starttls(1);

    # =====================#
    # RESTART STREAM
    # =====================#
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});
    like($client_read_data[3], qr{<\?xml version="1\.0"\?><stream\:stream from="xmpp\.example\.org" id="[0-9a-zA-Z]+" version="1\.0" xml\:lang=\"en\" xmlns:stream=\"http\:\/\/etherx\.jabber\.org\/streams\" xmlns=\"jabber\:client\">});
    is($client_read_data[4], q{<stream:features><mechanisms xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><mechanism>PLAIN</mechanism><mechanism>X-OAUTH2</mechanism></mechanisms></stream:features>});


    # =====================#
    # SASL AUTHENTICATION
    # =====================#
    $socket->emulate_client_write(q{<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='PLAIN'>VALID_PASS</auth>});

    is($delegate->get_last_event->{type}, 'auth');
    is($delegate->get_last_event->{data}->{stream_id}, 'dummy_id');
    is($delegate->get_last_event->{data}->{auth}->mechanism, 'PLAIN');
    is($delegate->get_last_event->{data}->{auth}->text, 'VALID_PASS');

    $stream->on_server_completed_sasl_auth(q{user2}, q{user2}, q{resource});
    is($client_read_data[5], '<success xmlns="urn:ietf:params:xml:ns:xmpp-sasl" />');

    is($stream->user_id, 'user2');

    # =====================#
    # RESTART STREAM
    # =====================#
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});

    like($client_read_data[6], qr{<\?xml version="1\.0"\?><stream\:stream from="xmpp\.example\.org" id="[0-9a-zA-Z]+" version="1\.0" xml\:lang=\"en\" xmlns:stream=\"http\:\/\/etherx\.jabber\.org\/streams\" xmlns=\"jabber\:client\">});
    is($client_read_data[7], '<stream:features><session xmlns="urn:ietf:params:xml:ns:xmpp-session" /><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind" /></stream:features>');


    # =====================#
    # RESOURCE BINDING
    # =====================#
    $socket->emulate_client_write(q{<iq type='set' id='bind_2'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'><resource>someresource</resource></bind></iq>});
    is($delegate->get_last_event->{type}, 'bind_request');
    is($delegate->get_last_event->{data}->{user_id}, 'user2');
    is($delegate->get_last_event->{data}->{stream_id}, 'dummy_id');

    ok($stream->bound_jid);
    ok(!$stream->is_bound);
    my $bound_result = Ocean::Stanza::DeliveryRequest::BoundJID->new({
        jid => Ocean::JID->new(q{user2@xmpp.example.org/resource}),
    });
    $stream->on_server_bound_jid($bound_result);
    ok($stream->bound_jid);
    ok($stream->is_bound);

    is($stream->bound_jid->as_string, q{user2@xmpp.example.org/resource});

    is($delegate->get_last_event->{type}, 'bound_jid');
    is($delegate->get_last_event->{data}->{stream_id}, 'dummy_id');
    is($delegate->get_last_event->{data}->{bound_jid}->as_string, 'user2@xmpp.example.org/resource');

    is($client_read_data[8], '<iq from="xmpp.example.org" id="bind_2" type="result"><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"><jid>user2@xmpp.example.org/resource</jid></bind></iq>');

    # =====================#
    # SESSION ESTABLISHMENT
    # =====================#
    $socket->emulate_client_write(q{<iq to='example.com' type='set' id='sess_1'><session xmlns='urn:ietf:params:xml:ns:xmpp-session'/></iq>});
    # XXX need <session /> ?
    is($client_read_data[9], '<iq from="xmpp.example.org" id="sess_1" type="result"><session xmlns="urn:ietf:params:xml:ns:xmpp-session" /></iq>');

    # =====================#
    # INITIAL PRESENCE
    # =====================#
    ok(!$stream->is_available, "stream should be 'ACTIVE' here");
    $socket->emulate_client_write(q{<presence />});
    ok($stream->is_available, "stream should be 'AVAILABLE' here");

    is($delegate->get_last_event->{type}, 'initial_presence');
    is($delegate->get_last_event->{data}->{bound_jid}->as_string, 'user2@xmpp.example.org/resource');
    is($delegate->get_last_event->{data}->{presence}->show, 'chat');

    # =====================#
    # ROSTER REQUEST
    # =====================#
    $socket->emulate_client_write(q{<iq type='get' id='roster_1'><query xmlns='jabber:iq:roster'/></iq>});
    is($delegate->get_last_event->{type}, 'roster_request');
    is($delegate->get_last_event->{data}->{bound_jid}->as_string, 'user2@xmpp.example.org/resource');
    is($delegate->get_last_event->{data}->{req}->id, 'roster_1');

    # =====================#
    # ROSTER RESULT
    # =====================#
    my $roster = Ocean::Stanza::DeliveryRequest::Roster->new({ items => [
        Ocean::Stanza::DeliveryRequest::RosterItem->new({
            jid      => q{taro@xmpp.example.org},
            nickname => q{Taro},
        }),
        Ocean::Stanza::DeliveryRequest::RosterItem->new({
            jid      => q{jiro@xmpp.example.org},
            nickname => q{Jiro},
        }),
    ] });
    $stream->on_server_delivered_roster(q{roster_1}, $roster);
    is($client_read_data[10], '<iq to="user2@xmpp.example.org/resource" from="user2@xmpp.example.org" id="roster_1" type="result"><query xmlns="jabber:iq:roster"><item jid="taro@xmpp.example.org" subscription="none" name="Taro"/><item jid="jiro@xmpp.example.org" subscription="none" name="Jiro"/></query></iq>');

    # =====================#
    # ROSTER PUSH
    # =====================#
    my $item = Ocean::Stanza::DeliveryRequest::RosterItem->new({
        jid      => q{saburo@xmpp.example.org},
        nickname => q{Saburo},
    });
    $stream->on_server_delivered_roster_push(q{roster_push_1}, $item);
    is($client_read_data[11], '<iq to="user2@xmpp.example.org/resource" from="user2@xmpp.example.org" id="roster_push_1" type="set"><query xmlns="jabber:iq:roster"><item jid="saburo@xmpp.example.org" subscription="none" name="Saburo"/></query></iq>');

    # =====================#
    # SEND MESSAGE
    # =====================#
    $socket->emulate_client_write(q{<message to="taro@xmpp.example.org" type="chat"><body>hoge</body></message>});

    is($delegate->get_last_event->{type}, 'message');
    is($delegate->get_last_event->{data}{bound_jid}->as_string, 'user2@xmpp.example.org/resource');
    is($delegate->get_last_event->{data}{to_jid}->as_string, 'taro@xmpp.example.org');
    #is($delegate->get_last_event->{data}{message}->type, 'chat');
    is($delegate->get_last_event->{data}{message}->body, 'hoge');

    # =====================#
    # RECEIVE MESSAGE
    # =====================#
    my $sender_jid_1 = Ocean::JID->new(q{user3@example.org/res1});
    my $message_1 = Ocean::Stanza::DeliveryRequest::ChatMessage->new({
        body    => q{body}, 
        type    => q{chat},
        subject => q{subject}, 
        thread  => q{thread},
        from    => $sender_jid_1,
        to      => Ocean::JID->new(q{user2@xmpp.example.org/resource}),
    });

    $stream->on_server_delivered_message($message_1);

    is($client_read_data[12], '<message type="chat" from="user3@example.org/res1" to="user2@xmpp.example.org/resource"><subject>subject</subject><thread>thread</thread><body>body</body></message>');

    # =====================#
    # SEND PRESENCE
    # =====================#

    $socket->emulate_client_write(q{<presence><show>away</show><status>sleeping</status></presence>});

    is($delegate->get_last_event->{type}, 'presence');
    is($delegate->get_last_event->{data}{bound_jid}->as_string, 'user2@xmpp.example.org/resource');
    is($delegate->get_last_event->{data}{presence}->show, 'away');
    is($delegate->get_last_event->{data}{presence}->status, 'sleeping');

    # =====================#
    # RECEIVE PRESENCE
    # =====================#
    my $sender_jid_2 = Ocean::JID->new(q{user4@example.org/res1});
    my $presence_1 = Ocean::Stanza::DeliveryRequest::Presence->new({
        status => q{foobar}, 
        show   => q{chat},
        from   => $sender_jid_2,
        to     => Ocean::JID->new(q{user2@xmpp.example.org/resource}),
    });
    $stream->on_server_delivered_presence($presence_1);
    is($client_read_data[13], '<presence from="user4@example.org/res1" to="user2@xmpp.example.org/resource"><status>foobar</status><show>chat</show><priority>0</priority></presence>');

    # =====================#
    # RECEIVED UNAVAILABLE PRESENCE
    # =====================#

    my $sender_jid_3 = Ocean::JID->new(q{user5@example.org/res1});
    $stream->on_server_delivered_unavailable_presence($sender_jid_3);
    is($client_read_data[14], '<presence from="user5@example.org/res1" to="user2@xmpp.example.org/resource" type="unavailable" />');

    # =====================#
    # VCARD REQUEST
    # =====================#
    $socket->emulate_client_write(q{<iq id="vcard_1" type="get" to="user7@xmpp.example.org"><vCard xmlns="vcard-temp"/></iq>});

    is($delegate->get_last_event->{type}, 'vcard_request');
    is($delegate->get_last_event->{data}{bound_jid}->as_string, 'user2@xmpp.example.org/resource');
    is($delegate->get_last_event->{data}{req}->id, 'vcard_1');
    is($delegate->get_last_event->{data}{req}->to->as_string, 'user7@xmpp.example.org');

    # =====================#
    # VCARD RESULT
    # =====================#
    my $vcard = Ocean::Stanza::DeliveryRequest::vCard->new({
        jid                => Ocean::JID->new(q{user3@example.org}), 
        nickname           => q{nick}, 
        photo_content_type => q{image/jpeg}, 
        photo              => q{DATA},
    });
    $stream->on_server_delivered_vcard('vcard_1', $vcard);

    is($client_read_data[15], '<iq to="user2@xmpp.example.org/resource" from="user3@example.org" id="vcard_1" type="result"><vCard xmlns="vcard-temp"><FN>nick</FN><PHOTO><TYPE>image/jpeg</TYPE><BINVAL>DATA</BINVAL></PHOTO></vCard></iq>');

    # =====================#
    # UNAVAILABLE PRESENCE
    # =====================#
    $socket->emulate_client_write(q{<presence type="unavailable" />});
    is($delegate->get_event_from_last(1)->{type}, 'unavailable');
    is($delegate->get_last_event->{type}, 'bound_closed');
}

TEST_CLOSE: {

    &reset();

    # =====================#
    # START STREAM
    # =====================#
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});

    # =====================#
    # REQUIRE STARTTLS
    # =====================#
    $socket->emulate_client_write(q{<starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>});

    # =====================#
    # TLS NEGOTIATION
    # =====================#
    $socket->emulate_client_starttls(1);

    # =====================#
    # RESTART STREAM
    # =====================#
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});


    # =====================#
    # SASL AUTHENTICATION
    # =====================#
    $socket->emulate_client_write(q{<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='PLAIN'>VALID_PASS</auth>});

    $stream->on_server_completed_sasl_auth(q{user2}, q{user2}, q{resource});

    # =====================#
    # RESTART STREAM
    # =====================#
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});

    # =====================#
    # RESOURCE BINDING
    # =====================#
    $socket->emulate_client_write(q{<iq type='set' id='bind_2'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'><resource>someresource</resource></bind></iq>});
    my $bound_result = Ocean::Stanza::DeliveryRequest::BoundJID->new({
        jid => Ocean::JID->new(q{user2@xmpp.example.org/resource}),
    });
    $stream->on_server_bound_jid($bound_result);

    # =====================#
    # SESSION ESTABLISHMENT
    # =====================#
    $socket->emulate_client_write(q{<iq to='example.com' type='set' id='sess_1'><session xmlns='urn:ietf:params:xml:ns:xmpp-session'/></iq>});
    # XXX need <session /> ?

    # =====================#
    # INITIAL PRESENCE
    # =====================#
    $socket->emulate_client_write(q{<presence />});

    # =====================#
    # CLOSE
    # =====================#
    $socket->close();
    is($delegate->get_event_from_last(1)->{type}, 'unavailable');
    is($delegate->get_last_event->{type}, 'bound_closed');
}

TEST_ERROR_ON_AVAILABLE: {
    &reset();

    # =====================#
    # START STREAM
    # =====================#
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});

    # =====================#
    # REQUIRE STARTTLS
    # =====================#
    $socket->emulate_client_write(q{<starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>});

    # =====================#
    # TLS NEGOTIATION
    # =====================#
    $socket->emulate_client_starttls(1);

    # =====================#
    # RESTART STREAM
    # =====================#
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});


    # =====================#
    # SASL AUTHENTICATION
    # =====================#
    $socket->emulate_client_write(q{<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='PLAIN'>VALID_PASS</auth>});

    $stream->on_server_completed_sasl_auth(q{user2}, q{user2}, q{resource});

    # =====================#
    # RESTART STREAM
    # =====================#
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});

    # =====================#
    # RESOURCE BINDING
    # =====================#
    $socket->emulate_client_write(q{<iq type='set' id='bind_2'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'><resource>someresource</resource></bind></iq>});

    my $bound_result = Ocean::Stanza::DeliveryRequest::BoundJID->new({
        jid => Ocean::JID->new(q{user2@xmpp.example.org/resource}),
    });
    $stream->on_server_bound_jid($bound_result);

    # =====================#
    # SESSION ESTABLISHMENT
    # =====================#
    $socket->emulate_client_write(q{<iq to='example.com' type='set' id='sess_1'><session xmlns='urn:ietf:params:xml:ns:xmpp-session'/></iq>});
    # XXX need <session /> ?

    # =====================#
    # INITIAL PRESENCE
    # =====================#
    $socket->emulate_client_write(q{<presence />});

    # =====================#
    # ERROR
    # =====================#
    $socket->emulate_client_write(q{<invalid></invalid>});
    is($client_read_data[ $#client_read_data - 1], '<stream:error><unsupported-stanza-type xmlns="urn:ietf:params:xml:ns:xmpp-streams" /><text xmlns="urn:ietf:params:xml:ns:xmpp-streams">Unsupported stanza: jabber:client:invalid</text></stream:error>');
    is($client_read_data[ $#client_read_data ], '</stream:stream>');
    is($delegate->get_event_from_last(1)->{type}, 'unavailable');
    is($delegate->get_last_event->{type}, 'bound_closed');
}

TEST_ERROR_ON_BOUND: {
    &reset();

    # =====================#
    # START STREAM
    # =====================#
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});

    # =====================#
    # REQUIRE STARTTLS
    # =====================#
    $socket->emulate_client_write(q{<starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>});

    # =====================#
    # TLS NEGOTIATION
    # =====================#
    $socket->emulate_client_starttls(1);

    # =====================#
    # RESTART STREAM
    # =====================#
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});


    # =====================#
    # SASL AUTHENTICATION
    # =====================#
    $socket->emulate_client_write(q{<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='PLAIN'>VALID_PASS</auth>});

    $stream->on_server_completed_sasl_auth(q{user2}, q{user2}, q{resource});

    # =====================#
    # RESTART STREAM
    # =====================#
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});

    # =====================#
    # RESOURCE BINDING
    # =====================#
    $socket->emulate_client_write(q{<iq type='set' id='bind_2'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'><resource>someresource</resource></bind></iq>});

    my $bound_result = Ocean::Stanza::DeliveryRequest::BoundJID->new({
        jid => Ocean::JID->new(q{user2@xmpp.example.org/resource}),
    });
    $stream->on_server_bound_jid($bound_result);

    # =====================#
    # SESSION ESTABLISHMENT
    # =====================#
    $socket->emulate_client_write(q{<iq to='example.com' type='set' id='sess_1'><session xmlns='urn:ietf:params:xml:ns:xmpp-session'/></iq>});
    # XXX need <session /> ?

    # =====================#
    # ERROR
    # =====================#
    $socket->emulate_client_write(q{<invalid></invalid>});
    is($client_read_data[ $#client_read_data - 1], '<stream:error><unsupported-stanza-type xmlns="urn:ietf:params:xml:ns:xmpp-streams" /><text xmlns="urn:ietf:params:xml:ns:xmpp-streams">Unsupported stanza: jabber:client:invalid</text></stream:error>');
    is($client_read_data[ $#client_read_data ], '</stream:stream>');

    isnt($delegate->get_event_from_last(1)->{type}, 'unavailable');
    is($delegate->get_last_event->{type}, 'bound_closed');
}

TEST_WITHOUT_TLS: {
    Ocean::Config->initialize(
        path   => q{t/data/config/example_no_tls.yml},
        schema => Ocean::Config::Schema->config,
    );
    Ocean::Config->instance;
    &reset();
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});

    like($client_read_data[0], qr{<\?xml version="1\.0"\?><stream\:stream from="xmpp\.example\.org" id="[0-9a-zA-Z]+" version="1\.0" xml\:lang=\"en\" xmlns:stream=\"http\:\/\/etherx\.jabber\.org\/streams\" xmlns=\"jabber\:client\">});
    is($client_read_data[1], '<stream:features><mechanisms xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><mechanism>PLAIN</mechanism><mechanism>X-OAUTH2</mechanism></mechanisms></stream:features>', "First features should not include TLS but SASL");
}

done_testing;
