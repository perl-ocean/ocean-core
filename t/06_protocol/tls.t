use strict;
use warnings;

use Test::More;

use Ocean::StreamComponent::Protocol::TLS;
use Ocean::Constants::ProtocolPhase;
use Ocean::Config;
use Ocean::Config::Schema;
use Try::Tiny;

use Ocean::Test::Spy::Stream;

my $config_file = q{t/data/config/example.ini};
Ocean::Config->initialize(
    path   => $config_file,
    schema => Ocean::Config::Schema->config,
);


TEST_INVALID_ORDER_RECEIVED: {
    my $protocol = Ocean::StreamComponent::Protocol::TLS->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);
    my $err;
    try {
        $protocol->on_client_received_starttls();
        $protocol->on_client_received_starttls();
    } catch {
        $err = $_;
    };
    is($err->type, 'host-unknown');
}

TEST_INVALID_ORDER_NEGOTIATED: {
    my $protocol = Ocean::StreamComponent::Protocol::TLS->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);
    my $err;
    try {
        $protocol->on_client_negotiated_tls();
    } catch {
        $err = $_;
    };
    is($err->type, 'host-unknown');
}

TEST_CORRECT_ORDER: {
    my $protocol = Ocean::StreamComponent::Protocol::TLS->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);
    $protocol->on_client_received_starttls();
    $protocol->on_client_negotiated_tls();

    ok($delegate->get_protocol_state(q{starttls}));
    is($delegate->get_protocol_state(q{next_phase}), Ocean::Constants::ProtocolPhase::SASL_STREAM);
}

TEST_UNIMPLEMENTED_CLIENT_EVENT_METHODS: {

    my $protocol = Ocean::StreamComponent::Protocol::TLS->new;
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
