use strict;
use warnings;

use Test::More;

use Ocean::XML::ElementEventHandler;
use Ocean::XML::Namespaces qw(CLIENT TLS SASL);
use Try::Tiny;
use XML::Parser::Expat;


my @elements;

my $handler = Ocean::XML::ElementEventHandler->new;
$handler->register_stream_event(sub {});
$handler->register_stanza_event(CLIENT, 'message',  sub { push(@elements, shift) });
$handler->register_stanza_event(CLIENT, 'presence', sub { push(@elements, shift) });
$handler->register_stanza_event(CLIENT, 'iq',       sub { push(@elements, shift) });
$handler->register_stanza_event(TLS,    'starttls', sub { push(@elements, shift) });
$handler->register_stanza_event(SASL,   'auth',     sub { push(@elements, shift) });
$handler->register_stanza_event(SASL,   'response', sub { push(@elements, shift) });

sub start_element {
    my ($expat, $localname, %attrs) = @_;
    my $ns    = $expat->namespace($localname);
    my $depth = $expat->depth;
    $handler->start_element($ns, $localname, $depth, \%attrs);
}

sub characters {
    my ($expat, $text) = @_;
    $handler->characters($text);
}

sub end_element {
    my ($expat, $localname) = @_;
    my $ns    = $expat->namespace($localname);
    my $depth = $expat->depth;
    $handler->end_element($ns, $localname, $depth);
}

my $parser = XML::Parser::ExpatNB->new(
    Namespaces       => 1, 
    ProtocolEncoding => 'UTF-8',
);
$parser->setHandlers(
    Start => sub { &start_element(@_) }, 
    Char  => sub { &characters(@_)    },
    End   => sub { &end_element(@_)   },
);

$parser->parse_more(q{<?xml version="1.0" encoding="utf-8"?>});
$parser->parse_more(q{<stream:stream xmlns:stream="http://etherx.jabber.org/streams" xmlns="jabber:client" to="xmpp.example.org" version="1.0">});
$parser->parse_more(q{<message type="chat" to="taro@xmpp.example.org"><body>foobar</body></message>});
$parser->parse_more('<iq id="roster_1" type="get"><query xmlns="jabber:iq:roster" /></iq>');
$parser->parse_more(q{<iq to="taro@xmpp.example.org/resource" from="taro@xmpp.example.org" id="roster_1" type="result"><query xmlns="jabber:iq:roster"><item jid="jiro@xmpp.example.org" subscription="both" name="Jiro"/><item jid="saburo@xmpp.example.org" subscription="from" name="Saburo"/><item jid="shiro@xmpp.example.org" subscription="from" name="Shiro"/></query></iq>});

is($elements[0]->as_string,'<message xmlns="jabber:client" to="taro@xmpp.example.org" type="chat"><body>foobar</body></message>');
is($elements[1]->as_string,'<iq xmlns="jabber:client" type="get" id="roster_1"><query xmlns="jabber:iq:roster"></query></iq>');
is($elements[2]->as_string,'<iq xmlns="jabber:client" to="taro@xmpp.example.org/resource" from="taro@xmpp.example.org" type="result" id="roster_1"><query xmlns="jabber:iq:roster"><item jid="jiro@xmpp.example.org" name="Jiro" subscription="both"></item><item jid="saburo@xmpp.example.org" name="Saburo" subscription="from"></item><item jid="shiro@xmpp.example.org" name="Shiro" subscription="from"></item></query></iq>');

done_testing();
