use strict;
use warnings;

use Test::More;
use Ocean::Config;
use Ocean::Config::Schema;
use Ocean::StreamComponent::Protocol::Active;
use Ocean::Constants::ProtocolPhase;
use Ocean::Stanza::Incoming::Presence;
use Ocean::Stanza::Incoming::RosterRequest;
use Try::Tiny;

use Ocean::Test::Spy::Stream;

my $config_file = q{t/data/config/example.ini};
Ocean::Config->initialize(
    path   => $config_file,
    schema => Ocean::Config::Schema->config,
);


TEST_INITIAL_PRESENCE: {

    my $protocol = Ocean::StreamComponent::Protocol::Active->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);

    my $presence = Ocean::Stanza::Incoming::Presence->new(q{chat}, q{foobar});
    $protocol->on_client_received_presence($presence);

    is($delegate->get_protocol_state(q{initial_presence})->show, 'chat');
    is($delegate->get_protocol_state(q{initial_presence})->status, 'foobar');

    #is($delegate->{next_phase}, Ocean::Constants::ProtocolPhase::AVAILABLE);
}

TEST_ROSTER_REQUEST: {
    my $protocol = Ocean::StreamComponent::Protocol::Active->new;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate($delegate);

    my $req = Ocean::Stanza::Incoming::RosterRequest->new(q{roster_iq_id});
    $protocol->on_client_received_roster_request($req);

    is($delegate->get_protocol_state(q{roster})->id, 'roster_iq_id');
    ok(!$delegate->get_protocol_state(q{next_phase}));

    my $presence = Ocean::Stanza::Incoming::Presence->new(q{chat}, q{foobar});
    $protocol->on_client_received_presence($presence);

    is($delegate->get_protocol_state(q{initial_presence})->show, 'chat');
    is($delegate->get_protocol_state(q{initial_presence})->status, 'foobar');

    #is($delegate->{next_phase}, Ocean::Constants::ProtocolPhase::AVAILABLE);
}

TEST_UNIMPLEMENTED_CLIENT_EVENT_METHODS: {

    my $protocol = Ocean::StreamComponent::Protocol::Active->new;
    my $delegate = Ocean::Test::Spy::Stream->new; 
    $protocol->set_delegate( $delegate );

    for my $method (qw(
        on_client_received_stream     
        on_client_received_message
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
