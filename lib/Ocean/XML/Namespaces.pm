package Ocean::XML::Namespaces;

use strict;
use warnings;

use base 'Exporter';

our %EXPORT_TAGS = (all => [qw(
    CLIENT
    COMPONENT
    STREAM
    STREAMS
    STANZAS
    SASL
    BIND
    SESSION
    TLS
    ROSTER
    REGISTER
    XML
    DISCO_INFO
    DISCO_ITEMS
    REGISTER_F
    DATA_FORM
    MUC
    MUC_USER
    MUC_OWNER
    X_DELAY
    DELAY
    PING
    VCARD
    VCARD_UPD
    PUBSUB
    PUBSUB_OWN
    PUBSUB_EV
    CAP
    CHAT_STATES
    VCARD_PHOTO
    ROSTER_PHOTO
    JINGLE_INFO
    XHTML_IM
    XHTML
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

use constant {
    CLIENT       => 'jabber:client',
    COMPONENT    => 'jabber:component:accept',
    STREAM       => 'http://etherx.jabber.org/streams',
    STREAMS      => 'urn:ietf:params:xml:ns:xmpp-streams',
    STANZAS      => 'urn:ietf:params:xml:ns:xmpp-stanzas',
    SASL         => 'urn:ietf:params:xml:ns:xmpp-sasl',
    BIND         => 'urn:ietf:params:xml:ns:xmpp-bind',
    SESSION      => 'urn:ietf:params:xml:ns:xmpp-session',
    TLS          => 'urn:ietf:params:xml:ns:xmpp-tls',
    ROSTER       => 'jabber:iq:roster',
    REGISTER     => 'jabber:iq:register',
    XML          => 'http://www.w3.org/XML/1998/namespace',
    DISCO_INFO   => 'http://jabber.org/protocol/disco#info',
    DISCO_ITEMS  => 'http://jabber.org/protocol/disco#items',
    REGISTER_F   => 'http://jabber.org/features/iq-register',
    DATA_FORM    => 'jabber:x:data',
    MUC          => 'http://jabber.org/protocol/muc',
    MUC_USER     => 'http://jabber.org/protocol/muc#user',
    MUC_OWNER    => 'http://jabber.org/protocol/muc#owner',
    X_DELAY      => 'jabber:x:delay',
    DELAY        => 'urn:xmpp:delay',
    PING         => 'urn:xmpp:ping',
    VCARD        => 'vcard-temp',
    VCARD_UPD    => 'vcard-temp:x:update',
    PUBSUB       => 'http://jabber.org/protocol/pubsub',
    PUBSUB_OWN   => 'http://jabber.org/protocol/pubsub#owner',
    PUBSUB_EV    => 'http://jabber.org/protocol/pubsub#event',
    CAP          => 'http://jabber.org/protocol/caps',
    CHAT_STATES  => 'http://jabber.org/protocol/chatstates',
    VCARD_PHOTO  => 'http://www.facebook.com/xmpp/vcard/photo',
    ROSTER_PHOTO => 'http://mixi.jp/ns/xmpp/roster/photo',
    JINGLE_INFO  => 'google:jingleinfo',
    XHTML_IM     => 'http://jabber.org/protocol/xhtml-im',
    XHTML        => 'http://www.w3.org/1999/xhtml',
};

1;
