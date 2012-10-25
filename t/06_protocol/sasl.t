use strict;
use warnings;

use Test::More;
use Ocean::Config;
use Ocean::Config::Schema;
use Ocean::StreamComponent::Protocol::SASL;
use Ocean::Stanza::Incoming::SASLAuth;
use Ocean::Constants::ProtocolPhase;
use Try::Tiny;

use Ocean::Test::Spy::Stream;

my $config_file = q{t/data/config/example.ini};
Ocean::Config->initialize(
    path   => q{t/data/config/example.yml},
    schema => Ocean::Config::Schema->config,
);

local $Log::Minimal::LOG_LEVEL = 'MUTE';
#local $Log::Minimal::LOG_LEVEL = 'DEBUG';

# Log::Minimal Debug Setting
local $ENV{LM_DEBUG} = 1 
    if $Log::Minimal::LOG_LEVEL eq 'DEBUG';


TEST_INVALID_ORDER_RECEIVED: {

    my $protocol = Ocean::StreamComponent::Protocol::SASL->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);

    my $auth = Ocean::Stanza::Incoming::SASLAuth->new('PLAIN', 'encoded_password_text');
    my $err;
    try {
        $protocol->on_client_received_sasl_auth($auth);
        $protocol->on_client_received_sasl_auth($auth);
    } catch {
        $err = $_;
    };
    is($err->type, q{policy-violation});
}

TEST_INVALID_ORDER_COMPLETED: {

    my $protocol = Ocean::StreamComponent::Protocol::SASL->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);

    my $err = '';
    try {
        $protocol->on_server_completed_sasl_auth(q{dummy_user_id});
    } catch {
        $err = $_;
    };
    ok($err->isa('Ocean::Error::ConditionMismatchedServerEvent'));
}

TEST_INVALID_ORDER_FAILED: {

    my $protocol = Ocean::StreamComponent::Protocol::SASL->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);

    my $err;
    try {
        $protocol->on_server_failed_sasl_auth();
    } catch {
        $err = $_;
    };
    ok($err->isa('Ocean::Error::ConditionMismatchedServerEvent'));
}

TEST_COLLECT_ORDER_COMPLETED: {
    my $protocol = Ocean::StreamComponent::Protocol::SASL->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);

    my $auth = Ocean::Stanza::Incoming::SASLAuth->new('PLAIN', 'encoded_password_text');
    $protocol->on_client_received_sasl_auth($auth);
    $protocol->on_server_completed_sasl_auth(q{dummy_user_id});

    is($delegate->get_protocol_state(q{handle_auth})->mechanism, 'PLAIN');
    is($delegate->get_protocol_state(q{handle_auth})->text, 'encoded_password_text');
    is($delegate->get_protocol_state(q{user_id}), 'dummy_user_id');
    is($delegate->get_protocol_state(q{next_phase}), Ocean::Constants::ProtocolPhase::BIND_AND_SESSION_STREAM);

    ok(!$delegate->get_protocol_state(q{failed_auth}));
}

TEST_COLLECT_ORDER_FAILED: {
    my $protocol = Ocean::StreamComponent::Protocol::SASL->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);

    my $auth = Ocean::Stanza::Incoming::SASLAuth->new('PLAIN', 'encoded_password_text');
    $protocol->on_client_received_sasl_auth($auth);
    $protocol->on_server_failed_sasl_auth();

    is($delegate->get_protocol_state(q{handle_auth})->mechanism, 'PLAIN');
    is($delegate->get_protocol_state(q{handle_auth})->text, 'encoded_password_text');
    is($delegate->get_protocol_state(q{failed_auth}), 'not-authorized');

    ok(!$delegate->get_protocol_state(q{next_phase}));
    ok(!$delegate->get_protocol_state(q{user_id}));
}

TEST_INVALID_MECH: {

    my $protocol = Ocean::StreamComponent::Protocol::SASL->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);

    my $auth = Ocean::Stanza::Incoming::SASLAuth->new('UNKNOWN', 'encoded_password_text');
    $protocol->on_client_received_sasl_auth($auth);

    is($delegate->get_protocol_state(q{failed_auth}), 'invalid-mechanism');

    ok(!$delegate->get_protocol_state(q{handle_auth}));
    ok(!$delegate->get_protocol_state(q{user_id}));
    ok(!$delegate->get_protocol_state(q{next_phase}));
}

TEST_X_OAUTH_MECH: {
    my $protocol = Ocean::StreamComponent::Protocol::SASL->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);

    my $auth = Ocean::Stanza::Incoming::SASLAuth->new('X-OAUTH2', 'encoded_token_text');
    $protocol->on_client_received_sasl_auth($auth);
    $protocol->on_server_completed_sasl_auth(q{dummy_user_id});

    is($delegate->get_protocol_state(q{handle_auth})->mechanism, 'X-OAUTH2');
    is($delegate->get_protocol_state(q{handle_auth})->text, 'encoded_token_text');
    is($delegate->get_protocol_state(q{user_id}), 'dummy_user_id');
    is($delegate->get_protocol_state(q{next_phase}), Ocean::Constants::ProtocolPhase::BIND_AND_SESSION_STREAM);

    ok(!$delegate->get_protocol_state(q{failed_auth}));
}

TEST_UNIMPLEMENTED_CLIENT_EVENT_METHODS: {

    my $protocol = Ocean::StreamComponent::Protocol::SASL->new;
    my $delegate = Ocean::Test::Spy::Stream->new; 
    $protocol->set_delegate( $delegate );

    for my $method (qw(
        on_client_received_stream     
        on_client_received_message
        on_client_received_presence
        on_client_received_bind_request
        on_client_received_session_request
        on_client_received_roster_request
        on_client_received_vcard_request
        on_client_received_ping
        on_client_received_disco_info_request
        on_client_received_disco_items_request
        on_client_received_starttls
        on_client_negotiated_tls
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
