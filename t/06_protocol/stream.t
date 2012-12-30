use strict;
use warnings;

use Test::More;

use Ocean::Config;
use Ocean::Config::Schema;

Ocean::Config->initialize(
    path   => q{t/data/config/example.yml},
    schema => Ocean::Config::Schema->config,
);

use Ocean::StreamComponent::Protocol::SASLStream;
use Ocean::StreamComponent::Protocol::TLSStream;
use Ocean::StreamComponent::Protocol::BindAndSessionStream;
use Storable ();
use Try::Tiny;
use Ocean::Constants::ProtocolPhase;
use Ocean::XML::Namespaces qw(TLS SASL BIND SESSION);

use Ocean::Test::Spy::Stream;

my $streamok = 0;
my $streamnotok = 0;
sub stream_ok {
    my ($protocol, $attr, $phase, $features) = @_;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate( $delegate );
    $protocol->on_client_received_stream($attr);
    is($delegate->get_protocol_state(q{next_phase}), $phase);
    is_deeply($delegate->get_protocol_state(q{features}), $features, "feature is ok");
}

sub stream_not_ok {
    my ($protocol, $attr, $errmsg) = @_;
    my $delegate = Ocean::Test::Spy::Stream->new;
    $protocol->set_delegate( $delegate );
    my $err = '';
    try {
        $protocol->on_client_received_stream($attr);
    } catch {
        $err = "$_";
    };
    is($err, $errmsg);
}

&stream_ok(
    Ocean::StreamComponent::Protocol::SASLStream->new,
    { to => 'xmpp.example.org', version => '1.0' },
    Ocean::Constants::ProtocolPhase::SASL,
    [ [ mechanisms => SASL, [
        [mechanism => 'PLAIN'],     
        [mechanism => 'X-OAUTH2'],
    ] ] ]
);

&stream_ok(
    Ocean::StreamComponent::Protocol::SASLStream->new,
    { to => 'xmpp.example.net', version => '1.0' },
    Ocean::Constants::ProtocolPhase::SASL,
    [ [ mechanisms => SASL, [
        [mechanism => 'PLAIN'],     
        [mechanism => 'X-OAUTH2'],
    ] ] ]
);

&stream_ok(
    Ocean::StreamComponent::Protocol::TLSStream->new,
    { to => 'xmpp.example.org', version => '1.0' },
    Ocean::Constants::ProtocolPhase::TLS,
    [[ starttls => TLS ]],
);

&stream_ok(
    Ocean::StreamComponent::Protocol::TLSStream->new,
    { to => 'xmpp.example.net', version => '1.0' },
    Ocean::Constants::ProtocolPhase::TLS,
    [[ starttls => TLS ]],
);

&stream_ok(
    Ocean::StreamComponent::Protocol::BindAndSessionStream->new,
    { to => 'xmpp.example.org', version => '1.0' },
    Ocean::Constants::ProtocolPhase::BIND_AND_SESSION,
    [
        [session => SESSION],
        [bind    => BIND],
    ],
);

&stream_ok(
    Ocean::StreamComponent::Protocol::BindAndSessionStream->new,
    { to => 'xmpp.example.net', version => '1.0' },
    Ocean::Constants::ProtocolPhase::BIND_AND_SESSION,
    [
        [session => SESSION],
        [bind    => BIND],
    ],
);

for my $stream ( 
    Ocean::StreamComponent::Protocol::SASLStream->new,
    Ocean::StreamComponent::Protocol::TLSStream->new,
    Ocean::StreamComponent::Protocol::BindAndSessionStream->new
) {

    # invalid host (not specified in the config)
    &stream_not_ok(
        $stream,
        { to => 'invalid.org', version => '1.0' },
        q{host-unknown: error},
    );

    # invalid host (no host)
    &stream_not_ok(
        $stream,
        { version => '1.0' },
        q{host-unknown: error},
    );

    # invalid version
    &stream_not_ok(
        $stream,
        { to => 'xmpp.example.org', version => '2.0' },
        q{unsupported-version: error},
    );

    # no version
    &stream_not_ok(
        $stream,
        { to => 'xmpp.example.org' },
        q{unsupported-version: error},
    );
}

done_testing;
