package Ocean::StreamComponent::IO::Encoder::JSON;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::IO::Encoder';

use JSON::XS;
use Log::Minimal;
use HTTP::Date;

use Ocean::Constants::StanzaErrorType;
use Ocean::Constants::StanzaErrorCondition;
use Ocean::Constants::SASLErrorType;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _json      => undef, 
        _on_write  => undef, 
        _in_stream => 0,
    }, $class;
    $self->{_json} = JSON::XS->new->utf8(1);
    return $self;
}

sub on_write {
    my ($self, $callback) = @_;
    $self->{_on_write} = $callback;
}

sub initialize {
    my $self = shift;
}

sub _write {
    my ($self, $packet) = @_;
    $self->{_on_write}->($packet);
}

sub send_http_handshake {
    my ($self, $handshake) = @_;
    # template method
}

sub send_http_handshake_error {
    my ($self, $code, $type, $message) = @_;
    $message ||= $type;
    my @lines = (
        sprintf(q{HTTP/1.1 %d %s}, $code, $type), 
        sprintf(q{Date: %s}, HTTP::Date::time2str(time())),
        "Connection: close",
        "Content-Type: text/plain",
        sprintf(q{Content-Length: %d}, length($message)),
    );
    my $header = join("\r\n", @lines);
    $header .= "\r\n\r\n";
    $self->_write($header . $message);
}

sub send_closing_http_handshake {
    my ($self, $handshake) = @_;
    # template method
}

sub send_packet {
    my ($self, $packet) = @_;
}

sub _encode_json {
    my ($self, $packet) = @_;
    return $self->{_json}->encode($packet);
}

=pod

Stream Initiation JSON desing

{
    stream: {
        id:      'foobar',
        from:    'xmppwebsocket.example.org',
        version: '1.0'
    }
}

=cut

sub send_initial_stream {
    my ($self, $id, $domain) = @_;

    $self->send_packet({ stream => {
        id      => $id,
        from    => $domain,
        version => '1.0',
    } });

    $self->{_in_stream} = 1;
}

sub send_end_of_stream {
    my $self = shift;
    # closing handshake
}

=pod

Stream Error JSON desing

{ error: { 
    type:    'stream',
    reason:  'policy-violation',
    message: 'invalid event'
} }

=cut

sub send_stream_error {
    my ($self, $type, $msg) = @_;
    return unless $self->{_in_stream};
    my $obj = { 
        type   => 'stream', 
    };
    if ($type) {
        $obj->{reason} = $type;
    }
    $obj->{message} = $msg if ($msg);
    $self->send_packet({
        error => $obj,
    });
}

=pod

features JSON design

{ 
    features:  [ 
        { type: 'bind'    },
        { type: 'session' },
        { type  : 'sasl'    ,
          params: [
            { key: 'mechanism', value: 'PLAIN'    }, 
            { key: 'mechanism', value: 'X-OAUTH2' }
          ] 
        },
    ] 
}
=cut

sub send_stream_features {
    my ($self, $features) = @_;
    my $obj = [];
    for my $feature ( @$features ) {
        if (@$feature > 2) {
            my $feature_obj = { 
                type   => $feature->[0], 
                params => [],
            };
            for my $param ( @{ $feature->[2] } ) {
                if (@$param > 1) {
                    push( @{ $feature_obj->{params} }, +{ 
                            key   => $param->[0], 
                            value => $param->[1] 
                    } );
                } else {
                    push( @{ $feature_obj->{params} }, +{ 
                            key => $param->[0], 
                    } );
                }
            }
            push( @$obj, $feature_obj );
        } else {
            push( @$obj, +{ type => $feature->[0] } );
        }
    }
    $self->send_packet({ features => $obj });
}

=pod

{
    sasl: {
        type: 'challenge',
        challenge: 'challengeword'
    }
}

=cut

sub send_sasl_challenge {
    my ($self, $challenge) = @_;
    $self->send_packet({ sasl => {
        type      => 'challenge',         
        challenge => $challenge || '',
    } });
}

=pod

{
    sasl: {
        type: 'success',
    }
}

=cut

sub send_sasl_success {
    my ($self) = @_;
    $self->send_packet({ sasl => { 
        type => 'success' 
    } });
}

=pod

{
    sasl: {
        type: 'failure',
        reason: 'reason'
    }
}

=cut

sub send_sasl_failure {
    my ($self, $type) = @_;
    $type ||= Ocean::Constants::SASLErrorType::NOT_AUTHORIZED;
    $self->send_packet({ sasl => {
        type   => 'failure',         
        reason => $type,
    } });
}

=pod

{
    sasl: {
        type: 'abort',
    }
}

=cut


sub send_sasl_abort {
    my ($self, $type) = @_;
    $self->send_packet({ sasl => {
        type => 'abort',
    } });
}

sub send_tls_proceed {
    my ($self, $type) = @_;
    # not supported on WebSocket
}

sub send_tls_failure {
    my ($self, $type) = @_;
    # not supported on WebSocket
}

=pod presence JSON desing

{
    presence: {
        from: 'sender@xmpp.example.org/foo',
        to: 'receiver@xmpp.example.org/bar',
        show: 'chat',
        status: 'foobar'
    }
}

=cut

sub send_presence {
    my ($self, $presence) = @_;

    my $from = $presence->from;
    my $to   = $presence->to;

    $from = $from->as_string if $from->isa("Ocean::JID");
    $to   = $to->as_string   if $to->isa("Ocean::JID");

    my $obj = {
        from => $from,
        to   => $to,
        show => $presence->show,
    };
    if ($presence->status) {
        $obj->{status} = $presence->status;
    }
    $self->send_packet({ presence => $obj });
}

=pod unavailable_presence JSON desing

{
    unavailable_presence: {
        from: 'sender@xmpp.example.org/foo',
        to: 'receiver@xmpp.example.org/bar'
    }
}

=cut

sub send_unavailable_presence {
    my ($self, $from, $to) = @_;
    $self->send_packet({ unavailable_presence => {
        from => $from,
        to   => $to,
    } });
}

sub send_message {
    my ($self, $message) = @_;

    my $from = $message->from;
    my $to   = $message->to;

    $from = $from->as_string if $from->isa("Ocean::JID");
    $to   = $to->as_string   if $to->isa("Ocean::JID");

    my $obj = {
        from => $from,
        to   => $to,
        type => $message->type, 
        body => $message->body,
    };
    if ($message->thread) {
        $obj->{thread} = $message->thread;
    }
    if ($message->subject) {
        $obj->{subject} = $message->subject;
    }
    $self->send_packet({ message => $obj });
}

=pod

Message Error JSON desing

{ error: { 
    type:    'message',
    reason:  'forbidden',
    message: 'invalid event'
} }

=cut

sub send_message_error {
    my ($self, $error) = @_;

    my $from       = $error->from;
    my $error_type = $error->error_type;
    my $condition  = $error->error_reason;
    my $text       = $error->error_text;

    my $obj = {
        type => 'message', 
    };
    if ($condition) {
        $obj->{reason} = $condition;
    }
    if ($text) {
        $obj->{message} = $text;
    }
    $self->send_packet({ error => $obj });
}

=pod pubsub event json design

{ event: {
    from: 'pubsub.xmpp.example.org',
    to:   'user@xmpp.example.org/resource',
    node: 'activity',
    items: [
        {
            id: "xxxxx01", 
            name: "activity_type1",
            fields: {
                key1: "value1",
                key2: "value2"
            }
        },
        {
            id: "xxxxx02", 
            name: "activity_type2",
            fields: {
                key1: "value1",
                key2: "value2"
            }
        },
    ]
} }

=cut

sub send_pubsub_event {
    my ($self, $event) = @_;
    # TODO
    # $self->send_packet({ event => $event->as_hash() });
}

=pod bind JSON design

{
    bind: {
        id: 'request_id',
        from: 'xmpp.example.org',
        jid: 'jiro@xmpp.example.org/resource',
    }
}

=cut

sub send_bind_result {
    my ($self, $id, $domain, $result) = @_;
    my $jid = $result->jid;
    $jid = $jid->as_string if $jid->isa('Ocean::JID');
    my $data = {
        id   => $id,
        from => $domain,
        jid  => $jid,
    };

    $data->{nickname} = defined $result->nickname 
        ? $result->nickname : '';
    $data->{photo_url} = defined $result->photo_url
        ? $result->photo_url : '';

    $self->send_packet({ bind => $data });
}

=pod session JSON desing

{
    session: {
        id: 'request_id',
        from: 'xmpp.example.org',
    }
}

=cut

sub send_session_result {
    my ($self, $id, $domain) = @_;
    $self->send_packet({ session => {
        id   => $id,
        from => $domain,
    } });
}

=pod

IQ Error JSON desing

{ error: { 
    type:    'query',
    id:      'foobar',
    reason:  'forbidden',
    message: 'invalid event'
} }

=cut


sub send_iq_error {
    my ($self, $error) = @_;

    my $error_type = $error->error_type;
    my $id         = $error->id;
    my $domain     = $error->from;
    my $condition  = $error->error_reason;
    my $message    = $error->error_text;

    my $obj = {
        type => 'query',
        id   => $id, 
    };
    if ($condition) {
        $obj->{reason} = $condition;
    }
    if ($message) {
        $obj->{message} = $message;
    }
    $self->send_packet({ error => $obj });
}

=pod roster JSON desing

{
    roster: {
        id:   'request_id',
        from: 'xmpp.example.org',
        to:   'jiro@xmpp.example.org/resource',
        items: [
            {
                jid: 'taro@xmpp.example.org',
                subscription: 'both',
                nickname: 'Taro',
                group: [ 'Friends', 'Family' ],
            },
            {
                jid: 'hanako@xmpp.example.org',
                subscription: 'to',
                nickname: 'Hanako',
                group: [ 'Friends' ],
            }
        ]
    }
}

=cut

sub send_roster_result {
    my ($self, $id, $domain, $to, $roster) = @_;
    my $obj = {
        id    => $id,
        from  => $domain,
        to    => $to,
        items => [],
    };
    for my $item ( @{ $roster->items } ) {
        my $jid = $item->jid;
        $jid = $jid->as_string if $jid->isa("Ocean::JID");
        my $item_obj = {
            jid          => $jid,
            subscription => $item->subscription,
            nickname     => $item->nickname,
            groups       => [],
        };
        $item_obj->{photo_url} = $item->photo_url 
            if $item->photo_url;
        for my $group ( @{ $item->groups } ) {
            push( @{ $item_obj->{groups} }, $group );
        }
        push( @{ $obj->{items} }, $item_obj );
    }
    $self->send_packet({ roster => $obj });
}

=pod RosterPush JSON design

{
    roster_push: {
        id:   'request_id',
        from: 'xmpp.example.org',
        to:   'jiro@xmpp.example.org/resource',
        item: {
            jid: 'taro@xmpp.example.org',
            subscription: 'both',
            group: [ 'Friends', 'Family' ]
        }
    }
}

=cut

sub send_roster_push {
    my ($self, $id, $domain, $to, $item) = @_;
    my $obj = {
        id    => $id,
        from  => $domain,
        to    => $to,
    };
    my $jid = $item->jid;
    $jid = $jid->as_string if $jid->isa("Ocean::JID");
    my $item_obj = {
        jid          => $jid,
        subscription => $item->subscription,
        groups       => [],
    };
    for my $group ( @{ $item->groups } ) {
        push( @{ $item_obj->{groups} }, $group );
    }
    $obj->{item} = $item_obj;
    $self->send_packet({ roster => $obj });
}

=pod pong JSON design

{
    pong: {
        id:   'ping_id',
        from: 'xmpp.example.org',
        to:   'jiro@xmpp.example.org'
    }
}

=cut

sub send_pong {
    my ($self, $id, $domain, $to) = @_;
    $self->send_packet({ pong => {
        id   => $id,
        to   => $to,
        from => $domain,
    } });
}

=pod vcard JSON design

TODO remove vcard support -> use roster and ext-value

{
    vcard: {
        id:        'request_id',
        owner:     'taro@xmpp.example.org',
        to:        'jiro@xmpp.example.org',
        nickname:  'Taro',
        photo_url: 'http://example.org/photo/taro'
    }
}

=cut

sub send_vcard {
    my ($self, $id, $to, $vcard) = @_;
    my $jid = $vcard->jid;
    $jid = $jid->as_string if $jid->isa("Ocean::JID");
    my $obj = { 
        id    => $id,
        owner => $jid,
        to    => $to,
    };
    if ($vcard->nickname) {
        $obj->{nickname} = $vcard->nickname;
    }
    if ($vcard->photo_url) {
        $obj->{photo_url} = $vcard->photo_url;
    }
    $self->send_packet({ vcard => $obj });
}

sub send_server_disco_info {
    # not supported yet
}

sub send_server_disco_items {
    # not supported yet
}

sub release {
    my $self = shift;
    $self->on_write(sub {});
}

1;
