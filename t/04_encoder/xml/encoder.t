use strict;
use warnings;

use Test::More;

use Ocean::StreamComponent::IO::Encoder::Default;
use Ocean::XML::Namespaces qw(BIND SASL SESSION);
use Ocean::Stanza::DeliveryRequest::BoundJID;
use Ocean::Stanza::DeliveryRequest::Roster;
use Ocean::Stanza::DeliveryRequest::RosterItem;
use Ocean::Stanza::DeliveryRequest::ChatMessage;
use Ocean::Stanza::DeliveryRequest::Presence;
use Ocean::Stanza::DeliveryRequest::vCard;
use Ocean::Stanza::DeliveryRequest::MessageError;
use Ocean::Stanza::DeliveryRequest::PresenceError;
use Ocean::Stanza::DeliveryRequest::IQError;

my $out = '';
my $encoder = Ocean::StreamComponent::IO::Encoder::Default->new;
$encoder->on_write(sub { $out = shift; });

$encoder->send_http_handshake({});
is($out, '');
$encoder->send_closing_http_handshake({});
is($out, '');

$encoder->send_initial_stream(q{foo}, q{xmpp.example.org});
is($out, q{<?xml version="1.0"?><stream:stream from="xmpp.example.org" id="foo" version="1.0" xml:lang="en" xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client">});

$encoder->send_end_of_stream();
is($out, q{</stream:stream>});

$encoder->send_stream_error('bad-format');
is($out, q{<stream:error xmlns:stream="http://etherx.jabber.org/streams"><bad-format xmlns="urn:ietf:params:xml:ns:xmpp-streams" /></stream:error>});

$encoder->initialize();
$encoder->send_initial_stream(q{foo}, q{xmpp.example.org});
$encoder->send_stream_error('bad-format');
is($out, q{<stream:error><bad-format xmlns="urn:ietf:params:xml:ns:xmpp-streams" /></stream:error>});

$encoder->send_stream_error('bad-format', q{foobar});
is($out, q{<stream:error><bad-format xmlns="urn:ietf:params:xml:ns:xmpp-streams" /><text xmlns="urn:ietf:params:xml:ns:xmpp-streams">foobar</text></stream:error>});

$encoder->send_stream_features([
    ['bind'     => BIND],
    [session    => SESSION],
    [mechanisms => SASL, [
        [mechanism => 'PLAIN'], 
        [mechanism => 'DIGEST-MD5'], 
    ]]
]);
is($out, q{<stream:features><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind" /><session xmlns="urn:ietf:params:xml:ns:xmpp-session" /><mechanisms xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><mechanism>PLAIN</mechanism><mechanism>DIGEST-MD5</mechanism></mechanisms></stream:features>});

$encoder->send_sasl_challenge(q{foobar});
is($out, q{<challenge xmlns="urn:ietf:params:xml:ns:xmpp-sasl">Zm9vYmFy</challenge>});

$encoder->send_sasl_failure();
is($out, q{<failure xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><not-authorized /></failure>});
$encoder->send_sasl_failure('invalid-authzid');
is($out, q{<failure xmlns="urn:ietf:params:xml:ns:xmpp-sasl"><invalid-authzid /></failure>});

$encoder->send_sasl_success();
is($out, q{<success xmlns="urn:ietf:params:xml:ns:xmpp-sasl" />});

$encoder->send_sasl_abort();
is($out, q{<abort xmlns="urn:ietf:params:xml:ns:xmpp-sasl" />});

$encoder->send_tls_proceed();
is($out, q{<proceed xmlns="urn:ietf:params:xml:ns:xmpp-tls" />});

$encoder->send_tls_failure();
is($out, q{<failure xmlns="urn:ietf:params:xml:ns:xmpp-tls" />});

# TODO define message/presence class
# TODO from_jid, to_jid
my $message = Ocean::Stanza::DeliveryRequest::ChatMessage->new({
    body => q{Hoge Hoge}, 
    subject => q{subject}, 
    thread => q{threadid},
    type => 'chat',
    from => q{sender@example.org/resource1},
    to => q{receiver@example.org/resource2}
});
$encoder->send_message($message);
is($out, q{<message type="chat" from="sender@example.org/resource1" to="receiver@example.org/resource2"><subject>subject</subject><thread>threadid</thread><body>Hoge Hoge</body></message>});

my $message_error = Ocean::Stanza::DeliveryRequest::MessageError->new({
    error_type => 'cancel',    
    from => 'example.org',
    error_reason => 'bad-request',
});
$encoder->send_message_error($message_error);
is($out, q{<message type="error" from="example.org"><error type="cancel"><bad-request xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error></message>});

$message_error = Ocean::Stanza::DeliveryRequest::MessageError->new({
    error_type   => 'cancel',    
    from         => 'example.org',
    error_reason => 'bad-request',
    error_text   => q{message@to is not found}
});
$encoder->send_message_error($message_error);

is($out, q{<message type="error" from="example.org"><error type="cancel"><bad-request xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/><text xmlns="urn:ietf:params:xml:ns:xmpp-stanzas">message@to is not found</text></error></message>});
my $presence = Ocean::Stanza::DeliveryRequest::Presence->new({
    status => q{free text here}, 
    show => q{away}, 
    image_hash => q{hash},
    from => q{sender@example.org/resource1},
    to => q{receiver@example.org/resource2}
});
# check accessors
$encoder->send_presence($presence);
is($out, q{<presence from="sender@example.org/resource1" to="receiver@example.org/resource2"><status>free text here</status><show>away</show><priority>0</priority><x xmlns="vcard-temp:x:update"><photo>hash</photo></x></presence>});

$encoder->send_unavailable_presence(q{sender@example.org/resource1}, q{receiver@example.org/resource1});
is($out, q{<presence from="sender@example.org/resource1" to="receiver@example.org/resource1" type="unavailable" />});

#$encoder->send_iq(type, id, domain, callback, to);
$encoder->send_iq(q{set}, q{foobar}, q{xmpp.example.org});
is($out, q{<iq from="xmpp.example.org" id="foobar" type="set"></iq>});
$encoder->send_iq(q{set}, q{foobar}, q{xmpp.example.org}, undef, q{receiver@example.org/resource1});
is($out, q{<iq to="receiver@example.org/resource1" from="xmpp.example.org" id="foobar" type="set"></iq>});

my $bound = Ocean::Stanza::DeliveryRequest::BoundJID->new({
    jid => q{receiver@example.org/boundresource} 
});
$encoder->send_bind_result(q{foobar}, q{xmpp.example.org}, $bound);
is($out, q{<iq from="xmpp.example.org" id="foobar" type="result"><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"><jid>receiver@example.org/boundresource</jid></bind></iq>});

$encoder->send_session_result(q{session_iq_id}, q{xmpp.example.org});
is($out, q{<iq from="xmpp.example.org" id="session_iq_id" type="result"><session xmlns="urn:ietf:params:xml:ns:xmpp-session" /></iq>});

#$encoder->send_iq_error(type, id, domain, condition, message);
my $iq_error;
$iq_error = Ocean::Stanza::DeliveryRequest::IQError->new({
    error_type => 'cancel',    
    id         => 'foobar1',
    from       => 'xmpp.example.org',
});
$encoder->send_iq_error($iq_error);
is($out, q{<iq id="foobar1" type="error" from="xmpp.example.org"><error type="cancel"><bad-request xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error></iq>});
$iq_error = Ocean::Stanza::DeliveryRequest::IQError->new({
    error_type   => 'auth',    
    error_reason => 'forbidden',
    id           => 'foobar2',
    from         => 'xmpp.example.org',
});
$encoder->send_iq_error($iq_error);
is($out, q{<iq id="foobar2" type="error" from="xmpp.example.org"><error type="auth"><forbidden xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error></iq>});
$iq_error = Ocean::Stanza::DeliveryRequest::IQError->new({
    error_type   => 'auth',    
    error_reason => 'forbidden',
    id           => 'foobar3',
    from         => 'xmpp.example.org',
    error_text   => q{Authorization Failed.},
});
$encoder->send_iq_error($iq_error);
is($out, q{<iq id="foobar3" type="error" from="xmpp.example.org"><error type="auth"><forbidden xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/><text xmlns="urn:ietf:params:xml:ns:xmpp-stanzas">Authorization Failed.</text></error></iq>});

my $item = Ocean::Stanza::DeliveryRequest::RosterItem->new({
    jid          => 'taro@example.com',
    subscription => 'none',
    nickname     => 'Taro',
    groups       => ['frineds', 'family'],
});
$encoder->send_roster_push(q{foobar10}, q{xmpp.example.org}, q{receiver@example.org/resource}, $item);
is($out, q{<iq to="receiver@example.org/resource" from="xmpp.example.org" id="foobar10" type="set"><query xmlns="jabber:iq:roster"><item jid="taro@example.com" subscription="none" name="Taro"><group>frineds</group><group>family</group></item></query></iq>});

my $item_nogroup = Ocean::Stanza::DeliveryRequest::RosterItem->new({
    jid          => 'taro@example.com',
    subscription => 'none',
    nickname     => 'Taro',
});
$encoder->send_roster_push(q{foobar10}, q{xmpp.example.org}, q{receiver@example.org/resource}, $item_nogroup);
is($out, '<iq to="receiver@example.org/resource" from="xmpp.example.org" id="foobar10" type="set"><query xmlns="jabber:iq:roster"><item jid="taro@example.com" subscription="none" name="Taro"/></query></iq>');

my $item_with_photo = Ocean::Stanza::DeliveryRequest::RosterItem->new({
    jid          => 'taro@example.com',
    subscription => 'none',
    nickname     => 'Taro',
    groups       => ['frineds', 'family'],
    photo_url    => q{http://example.org/user1.jpg},
});
$encoder->send_roster_push(q{foobar10}, q{xmpp.example.org}, q{receiver@example.org/resource}, $item_with_photo);
is($out, '<iq to="receiver@example.org/resource" from="xmpp.example.org" id="foobar10" type="set"><query xmlns="jabber:iq:roster"><item jid="taro@example.com" subscription="none" name="Taro"><group>frineds</group><group>family</group><photo_url xmlns="http://mixi.jp/ns/xmpp/roster/photo">http://example.org/user1.jpg</photo_url></item></query></iq>');

my $item2 = Ocean::Stanza::DeliveryRequest::RosterItem->new({
    jid          => 'jiro@example.com',
    subscription => 'none',
    nickname     => 'Jiro',
});
my $roster = Ocean::Stanza::DeliveryRequest::Roster->new({ items => [$item, $item2] });

$encoder->send_roster_result(q{foobar11}, q{xmpp.example.org}, q{receiver@example.org/resource}, $roster);
is($out, q{<iq to="receiver@example.org/resource" from="xmpp.example.org" id="foobar11" type="result"><query xmlns="jabber:iq:roster"><item jid="taro@example.com" subscription="none" name="Taro"><group>frineds</group><group>family</group></item><item jid="jiro@example.com" subscription="none" name="Jiro"/></query></iq>});

$encoder->send_pong(q{ping_iq_id}, q{xmpp.example.org});
is($out, q{<iq from="xmpp.example.org" id="ping_iq_id" type="result"></iq>});

my $vcard = Ocean::Stanza::DeliveryRequest::vCard->new({
    jid                => q{taro@xmpp.example.oerg}, 
    nickname           => q{Taro},
    photo_content_type => q{image/jpeg},
    photo              => q{encodedimage}
});
$encoder->send_vcard(q{vcard_iq_id}, q{receiver@example.org}, $vcard);
is($out, q{<iq to="receiver@example.org" from="taro@xmpp.example.oerg" id="vcard_iq_id" type="result"><vCard xmlns="vcard-temp"><FN>Taro</FN><PHOTO><TYPE>image/jpeg</TYPE><BINVAL>encodedimage</BINVAL></PHOTO></vCard></iq>});

$encoder->send_pong(q{ping_iq_id}, q{xmpp.example.org}, q{receiver@example.org/resource});
is($out, q{<iq to="receiver@example.org/resource" from="xmpp.example.org" id="ping_iq_id" type="result"></iq>});
#$encoder->send_server_disco_info(q{disco_info_iq_id}, q{xmpp.example.org}, q{receiver@example.org/resource});
#is($out, q{<iq to="receiver@example.org/resource" from="xmpp.example.org" id="disco_info_iq_id" type="result"><query xmlns="http://jabber.org/protocol/disco#info"><identity category="server" type="im" name="xmpp.example.org" /></query></iq>});
#$encoder->send_server_disco_items(q{disco_items_iq_id}, q{xmpp.example.org}, q{receiver@example.org/resource});
#is($out, q{<iq to="receiver@example.org/resource" from="xmpp.example.org" id="disco_items_iq_id" type="result"><query xmlns="http://jabber.org/protocol/disco#items" /></iq>});

done_testing();
