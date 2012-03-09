package Ocean::StreamComponent::IO::Decoder::JSON;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::IO::Decoder';

use Try::Tiny;
use JSON::XS;
use Log::Minimal;

use Ocean::Error;
use Ocean::Constants::EventType;
use Ocean::Constants::StanzaErrorType;
use Ocean::Constants::StanzaErrorCondition;
use Ocean::Constants::StreamErrorType;
use Ocean::Constants::WebSocketOpcode;

use Ocean::JSON::StanzaClassifier;
use Ocean::JSON::StanzaParserStore;

use constant {
    DELEGATE => 0,
    PROTOCOL => 1,
    JSON     => 2,
};

sub new {
    my ($class, %args) = @_;
    my $self = bless [
        undef,  # DELEGATE
        undef,  # PROTOCOL
        undef,  # JSON
    ], $class;

    $self->[PROTOCOL] = $args{protocol};
    $self->[JSON]     = JSON::XS->new->utf8(1);

    $self->_initialize_protocol();
    return $self;
}

sub _initialize_protocol {
    my $self = shift;
    $self->[PROTOCOL]->on_handshake(sub {
        $self->[DELEGATE]->on_received_handshake(@_);    
    });
    $self->[PROTOCOL]->on_read_frame(sub {
        $self->_handle_frame(@_);
    });
}

sub _handle_frame {
    my ($self, $op, $message) = @_;

    debugf("<Stream> <Decoder> handle frame {OP:%d, MESSAGE:%s}", $op, $message);

    if ($op == Ocean::Constants::WebSocketOpcode::CLOSE) {
        debugf("<Stream> <Decoder> Opcode is for closing handshake");
        $self->[DELEGATE]->on_received_closing_handshake();
    }
    elsif ($op == Ocean::Constants::WebSocketOpcode::TEXT_FRAME) {
        debugf("<Stream> <Decoder> Opcode is for text frame");
        if (length $message > 0) {
            $self->_handle_packet($message);
        } else {
            $self->[DELEGATE]->on_received_closing_handshake();
        }
    }
    elsif ($op == Ocean::Constants::WebSocketOpcode::PING) {
        debugf("<Stream> <Decoder> Opcode is for ping");
        # handle as ping packet?
        # or ignore?
    }
    else {
        debugf("<Stream> <Decoder> Opcode is for unsupported frame");
        # unsupported frame type
        # ignore
        # or close?
    }
}

sub _handle_packet {
    my ($self, $json) = @_;
    my $obj;
    debugf("<Stream> <Decoder> try to parse json, '%s'", $json);
    try {
        $obj = $self->[JSON]->decode($json);
    } catch {
        debugf("<Stream> <Decoder> failed to parse json");
        Ocean::Error::ProtocolError->throw(
            type => Ocean::Constants::StreamErrorType::INVALID_JSON,
            message =>
                q{Failed to parse json}, 
        );
    };
    $self->_handle_json($obj);
}

sub _handle_json {
    my ($self, $obj) = @_;

    my $event_type = Ocean::JSON::StanzaClassifier->classify($obj);
    return unless $event_type;

    $self->_dispatch_event($event_type, $obj);
}

sub _get_parser {
    my ($self, $event_type) = @_;
    return Ocean::JSON::StanzaParserStore->get_parser($event_type);
}

# FIXME
my %STANZA_METHOD_MAP = (
    Ocean::Constants::EventType::STREAM_INIT,
        q{on_received_stream},
    Ocean::Constants::EventType::SEND_MESSAGE,
        q{on_received_message},
    Ocean::Constants::EventType::SASL_AUTH_REQUEST,
        q{on_received_sasl_auth},
    Ocean::Constants::EventType::SEND_ROOM_MESSAGE,
        q{on_received_room_message},
    Ocean::Constants::EventType::BROADCAST_PRESENCE,
        q{on_received_presence},
    Ocean::Constants::EventType::BROADCAST_UNAVAILABLE_PRESENCE,
        q{on_received_unavailable_presence},
    Ocean::Constants::EventType::BIND_REQUEST,
        q{on_received_bind_request},
    Ocean::Constants::EventType::SESSION_REQUEST,
        q{on_received_session_request},
    Ocean::Constants::EventType::ROSTER_REQUEST,
        q{on_received_roster_request},
    Ocean::Constants::EventType::VCARD_REQUEST,
        q{on_received_vcard_request},
    Ocean::Constants::EventType::PING,
        q{on_received_ping},
    Ocean::Constants::EventType::DISCO_INFO_REQUEST,
        q{on_received_disco_info_request},
    Ocean::Constants::EventType::DISCO_ITEMS_REQUEST,
        q{on_received_disco_items_request},
);

sub _stanza_method_map {
    my $self = shift;
    return \%STANZA_METHOD_MAP;
}

sub _dispatch_event {
    my ($self, $event_type, $obj) = @_;

    debugf('<Stream> <Decoder> @%s', $event_type);

    my $event_method = $self->_stanza_method_map->{ $event_type };
    unless ($event_method) {
        warnf('<Stream> <Decoder> unknown stanza-event-type: %s', $event_type);
        return;
    }

    my $parser = $self->_get_parser($event_type);

    if ($parser) {
        my $stanza = $parser->parse($obj);
        $self->[DELEGATE]->$event_method($stanza) if $stanza;
    } else {
        # no arg
        $self->[DELEGATE]->$event_method();
    }
}

sub initialize {
    my $self = shift;
    # do nothing
}

sub set_delegate {
    my ($self, $delegate) = @_;
    $self->[DELEGATE] = $delegate;
}

sub release_delegate {
    my $self = shift;
    $self->[DELEGATE] = undef 
        if $self->[DELEGATE];
}

sub feed {
    my ($self, $data) = @_;
    $self->[PROTOCOL]->parse_more($data);
}

sub release {
    my $self = shift;
    $self->release_delegate();
    if ($self->[PROTOCOL]) {
        $self->[PROTOCOL]->release();
        $self->[PROTOCOL] = undef;
    }
}

1;
