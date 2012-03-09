use strict;
use warnings;

use Test::More tests => 11;

use Ocean::XML::ElementEventHandler;
use Try::Tiny;

my $handler = Ocean::XML::ElementEventHandler->new;

my %results;

sub clear_results {
    %results = ();
}

$handler->register_stream_event(sub {
   my $attr = shift;
   $results{stream_version} = $attr->{version};
   $results{stream_to}      = $attr->{to};
});

$handler->register_stanza_event("jabber:client", "message", sub {
    my $elem = shift;
    my $body = $elem->get_first_element('body');
    $results{body_text} = $body->text;
});

$handler->register_stanza_event("jabber:client", "presence", sub {
    my $elem = shift;
    $results{presence_type} = $elem->attr('type') || 'available';
    if ($results{presence_type} eq 'unavailable') {
        die "cause exception";
    }
});

$handler->register_stanza_event("jabber:client", "iq", sub {
    my $elem = shift;
    die "cause exception";
});

$handler->register_unknown_event(sub {
    $results{unknown} = 1;    
});

TEST_OPEN_STREAM: {

    &clear_results();

    $handler->start_element("http://etherx.jabber.org/streams", "stream", 0, { to => 'xmpp.example.org', version => '1.0' });

    is($results{stream_version}, '1.0');
    is($results{stream_to}, 'xmpp.example.org');
}

TEST_PUSH_MESSAGE: {

    &clear_results();

    $handler->start_element("jabber:client", "message", 1, { to => 'user1@xmpp.example.org', type => 'chat'  });
        $handler->start_element("jabber:client", "body", 2);
        $handler->characters("foobar");
        $handler->end_element("jabber:client", "body", 2);
    $handler->end_element("jabber:client", "message", 1);

    is($results{body_text}, 'foobar');
}

TEST_PUSH_PRESENCE: {

    &clear_results();

    $handler->start_element("jabber:client" , "presence", 1);
    $handler->end_element("jabber:client", "presence", 1);

    is($results{presence_type}, "available");

}

TEST_PUSH_SUBSCRIBE_PRESENCE: {

    &clear_results();

    $handler->start_element("jabber:client" , "presence", 1, { type => 'subscribe'});
    $handler->end_element("jabber:client", "presence", 1);

    is($results{presence_type}, "subscribe");

}

TEST_PUSH_IQ: {

    &clear_results();

    my $err; try {
        $handler->start_element("jabber:client" , "iq", 1);
        $handler->end_element("jabber:client", "iq", 1);
    } catch {
        $err = $_;
    };
    ok($err);
}

TEST_PUHS_PRESENCE_AGAIN_AFTER_EXCEPTION: {

    &clear_results();

    $handler->start_element("jabber:client" , "presence", 1);
    $handler->end_element("jabber:client", "presence", 1);

    is($results{presence_type}, "available");

}

TEST_UNKNOWN: {

    &clear_results();

    ok(!$results{unknown});

    $handler->start_element("jabber:client" , "foo", 1);
    $handler->end_element("jabber:client", "foo", 1);

    ok($results{unknown});
}

TEST_PUSH_UNAVAILABLE_PRESENCE: {

    &clear_results();

    $handler->start_element("jabber:client" , "presence", 1, { type => 'unavailable' });
    my $err; try {
        $handler->end_element("jabber:client", "presence", 1 );
    } catch {
        $err = $_;
    };

    ok($err);
}

TEST_PUSH_PRESENCE_AGAIN_AFTER_PRESENCE_EXCEPTION: {

    &clear_results();

    $handler->start_element("jabber:client" , "presence", 1);
    $handler->end_element("jabber:client", "presence", 1);

    is($results{presence_type}, "available");

}

