use strict;
use warnings;
use Test::More;

use Ocean::Config;
use Ocean::Config::Schema;
use Ocean::StreamComponent::Protocol::Available;
use Ocean::Constants::ProtocolPhase;
use Ocean::JID;
use Ocean::Stanza::Incoming::ChatMessage;
use Ocean::Stanza::Incoming::Presence;
use Ocean::Stanza::Incoming::RosterRequest;
use Ocean::Stanza::Incoming::vCardRequest;
use Ocean::Stanza::DeliveryRequest::vCard;
use Ocean::Stanza::DeliveryRequest::ChatMessage;
use Ocean::Stanza::DeliveryRequest::Presence;
use Ocean::Stanza::DeliveryRequest::Roster;
use Ocean::Stanza::DeliveryRequest::RosterItem;
use Try::Tiny;

use Ocean::Test::Spy::Stream;

my $config_file = q{t/data/config/example.yml};
Ocean::Config->initialize(
    path   => $config_file,
    schema => Ocean::Config::Schema->config,
);


TEST_CLIENT_MESSAGE: {
    my $protocol = Ocean::StreamComponent::Protocol::Available->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);

    my $to_jid = Ocean::JID->new(q{user2@example.org/resource});
    my $message = Ocean::Stanza::Incoming::ChatMessage->new($to_jid, q{foobar});
    $protocol->on_client_received_message($message);

    is($delegate->get_protocol_state(q{message_to_jid})->as_string, q{user2@example.org/resource});
    is($delegate->get_protocol_state(q{message})->body, 'foobar');
}

TEST_CLIENT_PRESENCE: {
    my $protocol = Ocean::StreamComponent::Protocol::Available->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);

    my $presence = Ocean::Stanza::Incoming::Presence->new(q{chat}, q{foobar});
    $protocol->on_client_received_presence($presence);

    is($delegate->get_protocol_state(q{presence})->show, 'chat');
    is($delegate->get_protocol_state(q{presence})->status, 'foobar');

}

TEST_CLIENT_ROSTER_REQUEST: {
    my $protocol = Ocean::StreamComponent::Protocol::Available->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);

    my $req = Ocean::Stanza::Incoming::RosterRequest->new(q{roster_iq_id});
    $protocol->on_client_received_roster_request($req);

    is($delegate->get_protocol_state(q{roster})->id, 'roster_iq_id');
}

TEST_CLIENT_VCARD_REQUEST: {
    my $protocol = Ocean::StreamComponent::Protocol::Available->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);

    my $req = Ocean::Stanza::Incoming::vCardRequest->new(q{vcard_iq_id},
        Ocean::JID->new(q{user2@example.org}));
    $protocol->on_client_received_vcard_request($req);

    is($delegate->get_protocol_state(q{vcard})->id, 'vcard_iq_id');
    is($delegate->get_protocol_state(q{vcard})->to->as_string, 'user2@example.org');
}

TEST_SERVER_MESSAGE: {
    my $protocol = Ocean::StreamComponent::Protocol::Available->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);

    my $sender_jid = Ocean::JID->new(q{user2@example.org/resource});
    my $message = Ocean::Stanza::DeliveryRequest::ChatMessage->new({
        type => 'chat',
        body => q{foobar},
        from => $sender_jid,
    });
    $protocol->on_server_delivered_message($message);

    is($delegate->get_protocol_state(q{server_message})->type, 'chat');
    is($delegate->get_protocol_state(q{server_message})->body, 'foobar');
    is($delegate->get_protocol_state(q{server_message_sender_jid})->as_string, q{user2@example.org/resource});
}

TEST_SERVER_PRESENCE: {
    my $protocol = Ocean::StreamComponent::Protocol::Available->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);

    my $sender_jid = Ocean::JID->new(q{user2@example.org/resource});
    my $presence = Ocean::Stanza::DeliveryRequest::Presence->new({
        status => q{foobar}, 
        show => q{chat},
        from => $sender_jid,
    });
    $protocol->on_server_delivered_presence($presence);

    is($delegate->get_protocol_state(q{server_presence_sender_jid})->as_string,
        'user2@example.org/resource');
    is($delegate->get_protocol_state(q{server_presence})->show, 'chat');
    is($delegate->get_protocol_state(q{server_presence})->status, 'foobar');
}

TEST_SERVER_UNAVAILABLE_PRESENCE: {
    my $protocol = Ocean::StreamComponent::Protocol::Available->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);

    my $sender_jid = Ocean::JID->new(q{user2@example.org/resource});
    $protocol->on_server_delivered_unavailable_presence($sender_jid);

    is($delegate->get_protocol_state(q{server_unavailable_presence_sender_jid})->as_string, 
        'user2@example.org/resource');
}

TEST_SERVER_DELIVERED_ROSTER: {
    my $protocol = Ocean::StreamComponent::Protocol::Available->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);
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
    $protocol->on_server_delivered_roster(q{roster_iq_id}, $roster);

    is($delegate->get_protocol_state(q{server_roster_iqid}), q{roster_iq_id});
    is($delegate->get_protocol_state(q{server_roster})->items->[0]->nickname, 'Taro');
    is($delegate->get_protocol_state(q{server_roster})->items->[1]->nickname, 'Jiro');
}

TEST_SERVER_DELIVERED_ROSTER_PUSH: {
    my $protocol = Ocean::StreamComponent::Protocol::Available->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);
    my $item = Ocean::Stanza::DeliveryRequest::RosterItem->new({
        jid      => 'taro@xmpp.example.org',
        nickname => 'Taro',
    });
    $protocol->on_server_delivered_roster_push(q{roster_push_iq_id}, $item);
    is($delegate->get_protocol_state(q{server_roster_item_iqid}), q{roster_push_iq_id});
    is($delegate->get_protocol_state(q{server_roster_item})->nickname, 'Taro');
}

TEST_SERVER_DELIVERED_VCARD: {
    my $protocol = Ocean::StreamComponent::Protocol::Available->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);
    my $vcard = Ocean::Stanza::DeliveryRequest::vCard->new({
        jid                => Ocean::JID->new(q{user3@example.org}), 
        nickname           => q{nick}, 
        photo_content_type => q{image/jpeg}, 
        photo              => q{DATA},
    });
    $protocol->on_server_delivered_vcard(q{vcard_iq_id}, $vcard);
    is($delegate->get_protocol_state(q{server_vcard_iqid}), q{vcard_iq_id});
    is($delegate->get_protocol_state(q{server_vcard})->photo_content_type, 'image/jpeg');
}

TEST_UNIMPLEMENTED_CLIENT_EVENT_METHODS: {

    my $protocol = Ocean::StreamComponent::Protocol::Available->new;
    my $delegate = Ocean::Test::Spy::Stream->new; 
    $protocol->set_delegate( $delegate );

    for my $method (qw(
        on_client_received_stream     
        on_client_received_bind_request
        on_client_received_session_request
        on_client_received_starttls
        on_client_negotiated_tls
        on_client_received_sasl_auth
        on_client_received_sasl_challenge_response
    )) {
        my $err;
        try {
            $protocol->$method();
        } catch {
            $err = $_;
        };
        ok($err, sprintf(q{'%s' shouldn't be implemented}, $method));
        is($err->type, 'policy-violation', sprintf(q{'%s' shouldn't be implemented}, $method));
    }
}

done_testing;
