use Test::More;

use Ocean::Config;
use Ocean::Config::Schema;

use Ocean::StreamComponent::IO;
use Ocean::StreamComponent::IO::Encoder::Default;
use Ocean::StreamComponent::IO::Decoder::Default;
use Ocean::StreamComponent::IO::Socket::Stub;
use Ocean::XML::Namespaces qw(BIND SESSION);
use Ocean::Stanza::DeliveryRequest::ChatMessage;
use Ocean::Stanza::DeliveryRequest::BoundJID;
use Ocean::Stanza::DeliveryRequest::Presence;
use Ocean::Stanza::DeliveryRequest::vCard;
use Ocean::JID;
use Ocean::Stanza::DeliveryRequest::Roster;
use Ocean::Stanza::DeliveryRequest::RosterItem;

use Ocean::Test::Spy::Stream;

use Log::Minimal;

local $Log::Minimal::PRINT = sub { };

Ocean::Config->initialize(
    path   => q{t/data/config/example.yml},
    schema => Ocean::Config::Schema->config,
);

my ($delegate, $socket, @client_read_data, $io);

sub reset {
    $io->release() if $io;
    $delegate = Ocean::Test::Spy::Stream->new;
    $socket   = Ocean::StreamComponent::IO::Socket::Stub->new;
    @client_read_data = ();
    $socket->client_on_read(sub { my $data = shift; push(@client_read_data, $data) });

    $io = Ocean::StreamComponent::IO->new(
        encoder => Ocean::StreamComponent::IO::Encoder::Default->new,
        decoder => Ocean::StreamComponent::IO::Decoder::Default->new,
        socket  => $socket,
    );
    $io->set_delegate($delegate);
}

TEST_CLIENT_EVENT_TIMEOUT: {
    &reset();
    $socket->emulate_client_timeout();
    is($delegate->get_io_history(0)->{type}, 'closed');
}

TEST_CLIENT_EVENT_CLOSE: {
    &reset();
    $socket->emulate_client_close();
    is($delegate->get_io_history(0)->{type}, 'closed');
}

TEST_CLIENT_EVENT_OPEN_STREAM: {
    &reset();
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});
    is($delegate->get_io_history(0)->{type}, 'stream');
    is($delegate->get_io_history(0)->{val}{attrs}{to}, 'xmpp.example.org');
    is($delegate->get_io_history(0)->{val}{attrs}{version}, '1.0');
}

TEST_CLIENT_EVENT_OPEN_INVALID_STREAM: {
    &reset();
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<unknown:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});
    is($delegate->get_io_history(0)->{type}, 'closed');
}

TEST_CLIENT_EVENT_MESSAGE: {
    &reset();
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});
    $socket->emulate_client_write(q{<message to="user2@xmpp.example.org/res" type="chat"><body>foobar</body></message>});
    is($delegate->get_io_history(1)->{type}, 'message');
    is($delegate->get_io_history(1)->{val}{to_jid}->as_string, 'user2@xmpp.example.org/res');
    is($delegate->get_io_history(1)->{val}{message}->body, 'foobar');
}

TEST_CLIENT_EVENT_PRESENCE: {
    &reset();
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});
    $socket->emulate_client_write(q{<presence></presence>});
    is($delegate->get_io_history(1)->{type}, 'presence');
    is($delegate->get_io_history(1)->{val}{presence}->show, 'chat');
}

TEST_CLIENT_EVENT_UNAVAILABLE_PRESENCE: {
    &reset();
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});
    $socket->emulate_client_write(q{<presence type="unavailable" />});
    is($delegate->get_io_history(1)->{type}, 'unavailable_presence');
}

TEST_CLIENT_EVENT_AUTH: {
    &reset();
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});
    $socket->emulate_client_write(q{<auth xmlns='urn:ietf:params:xml:ns:xmpp-sasl' mechanism='PLAIN'>MY_PASSWORD</auth>});
    is($delegate->get_io_history(1)->{type}, 'auth');
    is($delegate->get_io_history(1)->{val}{auth}->mechanism, 'PLAIN');
    is($delegate->get_io_history(1)->{val}{auth}->text, 'MY_PASSWORD');
}

TEST_CLIENT_EVENT_BIND: {
    &reset();
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});
    $socket->emulate_client_write(q{<iq type='set' id='bind_2'><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'><resource>someresource</resource></bind></iq>});
    is($delegate->get_io_history(1)->{type}, 'bind');
    is($delegate->get_io_history(1)->{val}{req}->id, 'bind_2');

    #is($delegate->get_io_history(1)->{val}{req}->resource, 'someresource');

    ok(!$delegate->get_io_history(1)->{val}{req}->resource);
}

TEST_CLIENT_EVENT_SESSION: {
    &reset();
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});
    $socket->emulate_client_write(q{<iq to='example.com' type='set' id='sess_1'><session xmlns='urn:ietf:params:xml:ns:xmpp-session'/></iq>});
    is($delegate->get_io_history(1)->{type}, 'session');
    is($delegate->get_io_history(1)->{val}{req}->id, 'sess_1');
}

TEST_CLIENT_EVENT_ROSTER: {
    &reset();
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});
    $socket->emulate_client_write(q{<iq to='example.com' type='get' id='roster_1'><query xmlns='jabber:iq:roster'/></iq>});
    is($delegate->get_io_history(1)->{type}, 'roster');
    is($delegate->get_io_history(1)->{val}{req}->id, 'roster_1');
}


TEST_CLIENT_EVENT_VCARD: {
    &reset();
    $socket->emulate_client_write(q{<?xml version="1.0" encoding="utf-8"?>});
    $socket->emulate_client_write(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});
    $socket->emulate_client_write(q{<iq to='example.com' type='get' id='vcard_1'><vCard xmlns='vcard-temp'/></iq>});
    is($delegate->get_io_history(1)->{type}, 'vcard');
    is($delegate->get_io_history(1)->{val}{req}->id, 'vcard_1');
}

TEST_PROTOCOL_EVENT_OPEN_STREAM: {
    &reset();
    my $stream_id = 'foobar';
    my $host      = 'xmpp.example.org';
    my $features  = [
        ['bind'    => BIND], 
        ['session' => SESSION],
    ];
    $io->on_protocol_open_stream($stream_id, $host, $features);

    is($client_read_data[0], '<?xml version="1.0"?><stream:stream from="xmpp.example.org" id="foobar" version="1.0" xml:lang="en" xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client">');
    is($client_read_data[1], '<stream:features><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind" /><session xmlns="urn:ietf:params:xml:ns:xmpp-session" /></stream:features>');
}

TEST_PROTOCOL_EVENT_STARTTLS_SUCCESS: {
    &reset();
    my $stream_id = 'foobar';
    my $host      = 'xmpp.example.org';
    my $features  = [
        ['bind'    => BIND], 
        ['session' => SESSION],
    ];
    $io->on_protocol_open_stream($stream_id, $host, $features);

    $io->on_protocol_starttls();
    $socket->emulate_client_starttls(1);

    is($delegate->get_io_history(0)->{type}, 'negotiated_tls');
}

TEST_PROTOCOL_EVENT_STARTTLS_FAILURE: {
    &reset();
    my $stream_id = 'foobar';
    my $host      = 'xmpp.example.org';
    my $features  = [
        ['bind'    => BIND], 
        ['session' => SESSION],
    ];
    $io->on_protocol_open_stream($stream_id, $host, $features);

    $io->on_protocol_starttls();
    $socket->emulate_client_starttls(0);

    is($delegate->get_io_history(0)->{type}, 'closed');
}

TEST_PROTOCOL_EVENT_COMPLETED_AUTH: {
    &reset();
    my $stream_id = 'foobar';
    my $host      = 'xmpp.example.org';
    my $features  = [
        ['bind'    => BIND], 
        ['session' => SESSION],
    ];
    $io->on_protocol_open_stream($stream_id, $host, $features);
    $io->on_protocol_completed_sasl_auth();
    is($client_read_data[2], '<success xmlns="urn:ietf:params:xml:ns:xmpp-sasl" />');
}

TEST_PROTOCOL_EVENT_FAILED_AUTH: {

    # FIXME
    # se of uninitialized value $name in concatenation (.) or string at
    # /Users/lyokato/perl5/perlbrew/perls/perl-5.12.1/lib/site_perl/5.12.1/XML/Writer.pm
    # line 287.

    &reset();
    my $stream_id = 'foobar';
    my $host      = 'xmpp.example.org';
    my $features  = [
        ['bind'    => BIND], 
        ['session' => SESSION],
    ];
    $io->on_protocol_open_stream($stream_id, $host, $features);
    $io->on_protocol_failed_sasl_auth();
    is($client_read_data[2], '<failure xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><not-authorized /></failure>');
}

TEST_PROTOCOL_EVENT_BOUND_JID: {
    &reset();
    my $stream_id = 'foobar';
    my $host      = 'xmpp.example.org';
    my $features  = [
        ['bind'    => BIND], 
        ['session' => SESSION],
    ];
    $io->on_protocol_open_stream($stream_id, $host, $features);
    my $bind_iq_id = q{bind_id_1};
    my $jid = Ocean::JID->new(q{user2@example.org/user2});
    my $result = Ocean::Stanza::DeliveryRequest::BoundJID->new({
        jid => $jid, 
    });
    $io->on_protocol_bound_jid($bind_iq_id, $host, $result);

    is($client_read_data[2], '<iq from="xmpp.example.org" id="bind_id_1" type="result"><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"><jid>user2@example.org/user2</jid></bind></iq>');
}


TEST_PROTOCOL_EVENT_STARTED_SESSION: {

    # FIXME
    # Use of uninitialized value $data in pattern match (m//) at
    # /Users/lyokato/perl5/perlbrew/perls/perl-5.12.1/lib/site_perl/5.12.1/XML/Writer.pm
    # line 346.
    # Use of uninitialized value $_[0] in join or string at /Users/lyokato/perl5/perlbrew/perls/perl-5.12.1/lib/site_perl/5.12.1/XML/Writer.pm line 1149
    &reset();
    my $stream_id = 'foobar';
    my $host      = 'xmpp.example.org';
    my $features  = [
        ['bind'    => BIND], 
        ['session' => SESSION],
    ];
    $io->on_protocol_open_stream($stream_id, $host, $features);
    my $session_iq_id = q{session_id_1};
    my $jid = Ocean::JID->new(q{user2@example.org/user2});
    my $result = Ocean::Stanza::DeliveryRequest::BoundJID->new({
        jid => $jid, 
    });
    $io->on_protocol_bound_jid($session_iq_id, $host, $result);
    is($client_read_data[2], '<iq from="xmpp.example.org" id="session_id_1" type="result"><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"><jid>user2@example.org/user2</jid></bind></iq>');
}

TEST_PROTOCOL_EVENT_DELIVERED_MESSAGE: {
    &reset();
    my $stream_id = 'foobar';
    my $host      = 'xmpp.example.org';
    my $features  = [
        ['bind'    => BIND], 
        ['session' => SESSION],
    ];
    $io->on_protocol_open_stream($stream_id, $host, $features);

    my $sender_jid   = Ocean::JID->new(q{user3@example.org/res1});
    my $receiver_jid = Ocean::JID->new(q{user4@example.org/res1});
    my $message = Ocean::Stanza::DeliveryRequest::ChatMessage->new({
        type    => q{chat}, 
        body    => q{body}, 
        subject => q{subject}, 
        thread  => q{thread},
        from    => $sender_jid,
        to      => $receiver_jid,
    });
    $io->on_protocol_delivered_message($message);
    is($client_read_data[2], '<message type="chat" from="user3@example.org/res1" to="user4@example.org/res1"><subject>subject</subject><thread>thread</thread><body>body</body></message>');
}

TEST_PROTOCOL_EVENT_DELIVERED_PRESENCE: {
    &reset();
    my $stream_id = 'foobar';
    my $host      = 'xmpp.example.org';
    my $features  = [
        ['bind'    => BIND], 
        ['session' => SESSION],
    ];
    $io->on_protocol_open_stream($stream_id, $host, $features);
    my $sender_jid   = Ocean::JID->new(q{user3@example.org/res1});
    my $receiver_jid = Ocean::JID->new(q{user4@example.org/res1});
    my $presence = Ocean::Stanza::DeliveryRequest::Presence->new({
        status => q{foobar}, 
        show => q{chat},
        from => $sender_jid,
        to => $receiver_jid,
    });
    $io->on_protocol_delivered_presence($presence);
    is($client_read_data[2], '<presence from="user3@example.org/res1" to="user4@example.org/res1"><status>foobar</status><show>chat</show><priority>0</priority></presence>');
}

TEST_PROTOCOL_EVENT_DELIVERED_UNAVAILABLE_PRESENCE: {
    &reset();
    my $stream_id = 'foobar';
    my $host      = 'xmpp.example.org';
    my $features  = [
        ['bind'    => BIND], 
        ['session' => SESSION],
    ];
    $io->on_protocol_open_stream($stream_id, $host, $features);
    my $sender_jid   = Ocean::JID->new(q{user3@example.org/res1});
    my $receiver_jid = Ocean::JID->new(q{user4@example.org/res1});
    $io->on_protocol_delivered_unavailable_presence($sender_jid, $receiver_jid);
    is($client_read_data[2], '<presence from="user3@example.org/res1" to="user4@example.org/res1" type="unavailable" />');
}

TEST_PROTOCOL_EVENT_DELIVERED_ROSTER: {
    &reset();
    my $stream_id = 'foobar';
    my $host      = 'xmpp.example.org';
    my $features  = [
        ['bind'    => BIND], 
        ['session' => SESSION],
    ];
    $io->on_protocol_open_stream($stream_id, $host, $features);
    my $roster = Ocean::Stanza::DeliveryRequest::Roster->new({ 
        items => [
            Ocean::Stanza::DeliveryRequest::RosterItem->new({
                jid      => q{taro@xmpp.example.org},
                nickname => q{Taro},
            }),
            Ocean::Stanza::DeliveryRequest::RosterItem->new({
                jid      => q{jiro@xmpp.example.org},
                nickname => q{Jiro},
            }),
        ] 
    });
    my $receiver_jid = Ocean::JID->new(q{user4@example.org/res1});
    $io->on_protocol_delivered_roster(q{roster_1}, $receiver_jid, $roster);
    is($client_read_data[2], '<iq to="user4@example.org/res1" from="user4@example.org" id="roster_1" type="result"><query xmlns="jabber:iq:roster"><item jid="taro@xmpp.example.org" subscription="none" name="Taro"/><item jid="jiro@xmpp.example.org" subscription="none" name="Jiro"/></query></iq>');
}

TEST_PROTOCOL_EVENT_DELIVERED_ROSTER_PUSH: {
    &reset();
    my $stream_id = 'foobar';
    my $host      = 'xmpp.example.org';
    my $features  = [
        ['bind'    => BIND], 
        ['session' => SESSION],
    ];
    $io->on_protocol_open_stream($stream_id, $host, $features);
    my $item = Ocean::Stanza::DeliveryRequest::RosterItem->new({
        jid      => 'taro@xmpp.example.org',
        nickname => 'Taro',
    });
    my $receiver_jid = Ocean::JID->new(q{user4@example.org/res1});
    $io->on_protocol_delivered_roster_push(q{roster_push_1}, $receiver_jid, $item);
    is($client_read_data[2], '<iq to="user4@example.org/res1" from="user4@example.org" id="roster_push_1" type="set"><query xmlns="jabber:iq:roster"><item jid="taro@xmpp.example.org" subscription="none" name="Taro"/></query></iq>');
}

TEST_PROTOCOL_EVENT_DELIVERED_VCARD: {
    &reset();
    my $stream_id = 'foobar';
    my $host      = 'xmpp.example.org';
    my $features  = [
        ['bind'    => BIND], 
        ['session' => SESSION],
    ];
    $io->on_protocol_open_stream($stream_id, $host, $features);
    my $vcard = Ocean::Stanza::DeliveryRequest::vCard->new({
        jid                => Ocean::JID->new(q{user3@example.org}), 
        nickname           => q{nick}, 
        photo_content_type => q{image/jpeg}, 
        photo              => q{DATA},
    });
    my $receiver_jid = Ocean::JID->new(q{user4@example.org/res1});
    $io->on_protocol_delivered_vcard(q{vcard_1}, $receiver_jid, $vcard);
    is($client_read_data[2], '<iq to="user4@example.org/res1" from="user3@example.org" id="vcard_1" type="result"><vCard xmlns="vcard-temp"><FN>nick</FN><PHOTO><TYPE>image/jpeg</TYPE><BINVAL>DATA</BINVAL></PHOTO></vCard></iq>');
}

TEST_PROTOCOL_EVENT_CLOSE: {
    &reset();
    my $stream_id = 'foobar';
    my $host      = 'xmpp.example.org';
    my $features  = [
        ['bind'    => BIND], 
        ['session' => SESSION],
    ];
    $io->on_protocol_open_stream($stream_id, $host, $features);
    $io->close();

    is($delegate->get_io_history(0)->{type}, 'closed');
}

done_testing;
