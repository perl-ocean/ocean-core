use strict;
use warnings;

use Test::More; 

use Ocean::StreamComponent::Protocol::BindAndSession;
use Ocean::Config;
use Ocean::Config::Schema;
use Ocean::JID;
use Ocean::Constants::ProtocolPhase;
use Ocean::Stanza::Incoming::BindResource;
use Ocean::Stanza::Incoming::Session;
use Try::Tiny;

use Ocean::Test::Spy::Stream;

my $config_file = q{t/data/config/example.ini};
Ocean::Config->initialize(
    path   => $config_file,
    schema => Ocean::Config::Schema->config,
);


TEST_INVALID_ORDER_BIND_BIND: {
    my $protocol = Ocean::StreamComponent::Protocol::BindAndSession->new;
    my $delegate = Ocean::Test::Spy::Stream->new; 
    $protocol->set_delegate( $delegate );
    my $bind_request = Ocean::Stanza::Incoming::BindResource->new(q{my_bind_iq_id}, q{my_resource});
    ok(!$delegate->get_protocol_state(q{bind_request}));
    $protocol->on_client_received_bind_request($bind_request);
    is($delegate->get_protocol_state(q{bind_request}), 1);
    my $err;
    try { 
        $protocol->on_client_received_bind_request($bind_request);
    } catch {
        $err = $_;
    };
    ok($err->isa('Ocean::Error::ProtocolError'));
    is($err->type, q{policy-violation});
}

TEST_INVALID_ORDER_SESSION_SESSION: {
    my $protocol = Ocean::StreamComponent::Protocol::BindAndSession->new;
    my $delegate = Ocean::Test::Spy::Stream->new; 
    $protocol->set_delegate( $delegate );
    my $request = Ocean::Stanza::Incoming::Session->new(q{my_session_iq_id});
    ok(!$delegate->get_protocol_state(q{session_iq_id}));
    $protocol->on_client_received_session_request($request);
    is($delegate->get_protocol_state(q{session_iq_id}), q{my_session_iq_id});
    my $err;
    try { 
        $protocol->on_client_received_session_request($request);
    } catch {
        $err = $_;
    };
    ok($err->isa('Ocean::Error::ProtocolError'));
    is($err->type, q{policy-violation});
}

TEST_INVALID_ORDER_BIND_SESSION: {
    my $protocol = Ocean::StreamComponent::Protocol::BindAndSession->new;
    my $delegate = Ocean::Test::Spy::Stream->new; 
    $protocol->set_delegate( $delegate );

    my $bind_request = Ocean::Stanza::Incoming::BindResource->new(q{my_bind_iq_id}, q{my_resource});
    ok(!$delegate->get_protocol_state(q{bind_request}));
    $protocol->on_client_received_bind_request($bind_request);
    is($delegate->get_protocol_state(q{bind_request}), 1);

    my $request = Ocean::Stanza::Incoming::Session->new(q{my_session_iq_id});
    my $err;
    try { 
        $protocol->on_client_received_session_request($request);
    } catch {
        $err = $_;
    };
    ok($err->isa('Ocean::Error::ProtocolError'));
    is($err->type, q{policy-violation});
}

TEST_INVALID_ORDER_BOUND: {
    my $protocol = Ocean::StreamComponent::Protocol::BindAndSession->new;
    my $delegate = Ocean::Test::Spy::Stream->new; 
    $protocol->set_delegate( $delegate );
    my $jid = Ocean::JID->new(q{user1@example.org/example});
    my $err;
    try {
        $protocol->on_server_bound_jid($jid);
    } catch {
        $err = $_;
    };
    ok($err->isa(q{Ocean::Error::ConditionMismatchedServerEvent}));
}

TEST_INVALID_ORDER_SESSION_BOUND: {
    my $protocol = Ocean::StreamComponent::Protocol::BindAndSession->new;
    my $delegate = Ocean::Test::Spy::Stream->new; 
    $protocol->set_delegate( $delegate );

    my $request = Ocean::Stanza::Incoming::Session->new(q{my_session_iq_id});
    ok(!$delegate->get_protocol_state(q{session_iq_id}));
    $protocol->on_client_received_session_request($request);
    is($delegate->get_protocol_state(q{session_iq_id}), q{my_session_iq_id});

    my $jid = Ocean::JID->new(q{user1@example.org/example});
    my $err;
    try {
        $protocol->on_server_bound_jid($jid);
    } catch {
        $err = $_;
    };
    ok($err->isa(q{Ocean::Error::ConditionMismatchedServerEvent}));
}

TEST_CORRECT_ORDER_BIND_BOUND_SESSION: {
    my $protocol = Ocean::StreamComponent::Protocol::BindAndSession->new;
    my $delegate = Ocean::Test::Spy::Stream->new; 
    $protocol->set_delegate( $delegate );

    my $bind_request = Ocean::Stanza::Incoming::BindResource->new(q{my_bind_iq_id}, q{my_resource});
    ok(!$delegate->get_protocol_state(q{bind_request}));
    $protocol->on_client_received_bind_request($bind_request);
    is($delegate->get_protocol_state(q{bind_request}), 1);

    my $jid = Ocean::JID->new(q{user1@example.org/example});
    $protocol->on_server_bound_jid($jid);

    is($delegate->get_protocol_state(q{bound_iq_id}), 'my_bind_iq_id');
    is($delegate->get_protocol_state(q{bound_jid})->as_string, 'user1@example.org/example');

    ok(!$delegate->get_protocol_state(q{next_phase}));

    my $request = Ocean::Stanza::Incoming::Session->new(q{my_session_iq_id});
    ok(!$delegate->get_protocol_state(q{session_iq_id}));
    $protocol->on_client_received_session_request($request);
    is($delegate->get_protocol_state(q{session_iq_id}), q{my_session_iq_id});

    is($delegate->get_protocol_state(q{next_phase}), Ocean::Constants::ProtocolPhase::ACTIVE);
}

TEST_CORRECT_ORDER_SESSION_BIND_BOUND: {
    my $protocol = Ocean::StreamComponent::Protocol::BindAndSession->new;
    my $delegate = Ocean::Test::Spy::Stream->new; 
    $protocol->set_delegate( $delegate );

    my $request = Ocean::Stanza::Incoming::Session->new(q{my_session_iq_id});
    ok(!$delegate->get_protocol_state(q{session_iq_id}));
    $protocol->on_client_received_session_request($request);
    is($delegate->get_protocol_state(q{session_iq_id}), q{my_session_iq_id});

    my $bind_request = Ocean::Stanza::Incoming::BindResource->new(q{my_bind_iq_id}, q{my_resource});
    ok(!$delegate->get_protocol_state(q{bind_request}));
    $protocol->on_client_received_bind_request($bind_request);
    is($delegate->get_protocol_state(q{bind_request}), 1);

    ok(!$delegate->get_protocol_state(q{next_phase}));

    my $jid = Ocean::JID->new(q{user1@example.org/example});
    $protocol->on_server_bound_jid($jid);

    is($delegate->get_protocol_state(q{bound_iq_id}), 'my_bind_iq_id');
    is($delegate->get_protocol_state(q{bound_jid})->as_string, 'user1@example.org/example');

    is($delegate->get_protocol_state(q{next_phase}), Ocean::Constants::ProtocolPhase::ACTIVE);
}

TEST_UNIMPLEMENTED_CLIENT_EVENT_METHODS: {

    my $protocol = Ocean::StreamComponent::Protocol::BindAndSession->new;
    my $delegate = Ocean::Test::Spy::Stream->new; 
    $protocol->set_delegate( $delegate );

#        on_client_received_bind_request
#        on_client_received_session_request
    for my $method (qw(
        on_client_received_stream     
        on_client_received_message
        on_client_received_presence
        on_client_received_roster_request
        on_client_received_vcard_request
        on_client_received_ping
        on_client_received_disco_info_request
        on_client_received_disco_items_request
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
