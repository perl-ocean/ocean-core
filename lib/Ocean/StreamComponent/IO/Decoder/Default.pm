package Ocean::StreamComponent::IO::Decoder::Default;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::IO::Decoder';

use XML::Parser::Expat;
use Try::Tiny;
use Log::Minimal;
use Encode;

use Ocean::XML::Namespaces qw(
    CLIENT 
    SASL 
    TLS 
);

use Ocean::Error;
use Ocean::Constants::StreamErrorType;

use Ocean::XML::ElementEventHandler;
use Ocean::XML::StanzaParserStore;
use Ocean::XML::StanzaClassifier::Message;
use Ocean::XML::StanzaClassifier::Presence;
use Ocean::XML::StanzaClassifier::IQ;

use constant {
    PARSER     => 0,
    HANDLER    => 1,
    DELEGATE   => 2,
    IS_PARSING => 3,
    NEED_INIT  => 4,
};

=head1 NAME

Ocean::StreamComponent::IO::Decoder::Default - decoder for standard XML stream

=head1 SYNOPSIS

    my $decoder = Ocean::StreamComponent::IO::Decoder::Default->new;
    $decoder->set_delegate($self):

=head1 DESCRIPTION

This module is to handle XML stream for XMPP.
Using SAX parser, parse input stream and invoke callbacks
for stanza-received-event or stream-start-event.

=head1 METHODS

=head2 new

=cut

sub new {
    my ($class, %args) = @_;
    my $self = bless [
        undef,                    # PARSER
        undef,                    # HANDLER
        undef,                    # DELEGATE
        0,                        # IS_PARSING
        0,                        # NEED_INIT
    ], $class;
    $self->initialize();
    return $self;
}

=head2 initialize

Initialize internal parser and event-handler.

=cut

sub initialize {
    my $self = shift;
    if ($self->[IS_PARSING]) {
        $self->[NEED_INIT] = 1;
    } else {
        $self->_do_initialize();
    }
}

sub _do_initialize {
    my $self = shift;

    # setup parser
    $self->_release_parser();
    $self->[PARSER] = $self->_build_parser();

    # setup handler
    $self->_release_handler();
    $self->[HANDLER] = $self->_build_handler();
}

=head2 set_delegate($delegate)

=cut

sub set_delegate {
    my ($self, $delegate) = @_;
    $self->[DELEGATE] = $delegate;
}

=head2 feed($data)

Pass a data which is a part of xml stream.
That is processed by SAX-parser and invoke callback if 
found stream-start-tag or stanza elements.

=cut

sub feed {
    my ($self, $data) = @_;
    $data = Encode::decode_utf8($data);
    try {
        $self->[IS_PARSING] = 1;
        $self->[PARSER]->parse_more($data);
        $self->[IS_PARSING] = 0;
        if ($self->[NEED_INIT]) {
            $self->[NEED_INIT] = 0;
            $self->_do_initialize();
        }
    } catch {
        warnf("<Stream> <Decoder> Received invalid XML: %s", "$_");
        Ocean::Error::ProtocolError->throw(
            type => Ocean::Constants::StreamErrorType::INVALID_XML,
        );
    };
}

=head2 depth

Returns depth of XML parsed currenty.

=cut

sub depth {
    my $self = shift;
    return $self->[PARSER]->depth();
}

sub release_delegate {
    my $self = shift;
    $self->[DELEGATE] = undef if $self->[DELEGATE];
}

sub _release_parser {
    my $self = shift;
    return unless $self->[PARSER];
    $self->[PARSER]->release();
    $self->[PARSER] = undef;
}

sub _release_handler {
    my $self = shift;
    return unless $self->[HANDLER];
    $self->[HANDLER]->release();
    $self->[HANDLER] = undef;
}


# FIXME
my %STANZA_METHOD_MAP = (
    Ocean::Constants::EventType::SEND_MESSAGE,
        q{on_received_message},
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
    Ocean::Constants::EventType::SEND_IQ_TOWARD_USER,
        q{on_received_iq_toward_user},
    Ocean::Constants::EventType::SEND_IQ_TOWARD_ROOM_MEMBER,
        q{on_received_iq_toward_room_member},
    Ocean::Constants::EventType::ROOM_INFO_REQUEST,
        q{on_received_room_info_request},
    Ocean::Constants::EventType::ROOM_SERVICE_INFO_REQUEST,
        q{on_received_room_service_info_request},
    Ocean::Constants::EventType::ROOM_LIST_REQUEST,
        q{on_received_room_list_request},
    Ocean::Constants::EventType::ROOM_MEMBERS_LIST_REQUEST,
        q{on_received_room_members_list_request},
    Ocean::Constants::EventType::ROOM_INVITATION,
        q{on_received_room_invitation},
    Ocean::Constants::EventType::ROOM_INVITATION_DECLINE,
        q{on_received_room_invitation_decline},
    Ocean::Constants::EventType::ROOM_PRESENCE,
        q{on_received_room_presence},
    Ocean::Constants::EventType::LEAVE_ROOM_PRESENCE,
        q{on_received_leave_room_presence},
    Ocean::Constants::EventType::JINGLE_INFO_REQUEST,
        q{on_received_jingle_info_request},
);

sub _stanza_method_map {
    my $self = shift;
    return \%STANZA_METHOD_MAP;
}

sub _get_parser {
    my ($self, $event_type) = @_;
    return Ocean::XML::StanzaParserStore->get_parser($event_type);
}

sub _dispatch_event {
    my ($self, $event_type, $elem) = @_;

    debugf('<Stream> <Decoder> @%s', $event_type);

    my $event_method = $self->_stanza_method_map->{ $event_type };
    unless ($event_method) {
        warnf('<Stream> <Decoder> unknown stanza-event-type: %s', $event_type);
        return;
    }

    my $parser = $self->_get_parser($event_type);

    if ($parser) {
        my $stanza = $parser->parse($elem);
        $self->[DELEGATE]->$event_method($stanza) if $stanza;
    } else {
        # no arg
        $self->[DELEGATE]->$event_method();
    }
}

sub _handle_message_event {
    my ($self, $elem) = @_;

    my $event_type = 
        Ocean::XML::StanzaClassifier::Message->classify($elem);
    return unless $event_type;

    $self->_dispatch_event($event_type, $elem);
}

sub _handle_presence_event {
    my ($self, $elem) = @_;

    my $event_type = 
        Ocean::XML::StanzaClassifier::Presence->classify($elem);
    return unless $event_type;

    $self->_dispatch_event($event_type, $elem);
}

sub _handle_iq_event {
    my ($self, $elem) = @_;

    my $event_type = 
        Ocean::XML::StanzaClassifier::IQ->classify($elem);
    return unless $event_type;

    $self->_dispatch_event($event_type, $elem);
}

sub _handle_starttls_event {
    my $self = shift;
    $self->[DELEGATE]->on_received_starttls();
}

sub _handle_sasl_auth_event {
    my ($self, $elem) = @_;

    my $auth = Ocean::XML::StanzaParser::SASLAuth->parse($elem);

    $self->[DELEGATE]->on_received_sasl_auth($auth) if $auth;
}

sub _handle_sasl_challenge_response_event {
    my ($self, $elem) = @_;
    my $response = 
        Ocean::XML::StanzaParser::SASLChallengeResponse->parse($elem);
    $self->[DELEGATE]->on_received_sasl_challenge_response($response) 
        if $response;

}

my @ELEMENT_EVENT_MAP = (
    [ CLIENT, q{message},   q{_handle_message_event}                 ],
    [ CLIENT, q{presence},  q{_handle_presence_event}                ],
    [ CLIENT, q{iq},        q{_handle_iq_event}                      ],
    [ TLS,    q{starttls},  q{_handle_starttls_event}                ],
    [ SASL,   q{auth},      q{_handle_sasl_auth_event}               ],
    [ SASL,   q{response},  q{_handle_sasl_challenge_response_event} ],
);

sub _build_handler {
    my $self = shift;

    my $handler = Ocean::XML::ElementEventHandler->new;

    $handler->register_stream_event(
        sub { $self->[DELEGATE]->on_received_stream(@_) }
    );

    for my $map (@ELEMENT_EVENT_MAP) {
        my ($ns, $name, $meth) = @$map;
        $handler->register_stanza_event($ns, $name, 
            sub { $self->$meth(@_) });
    }

    $handler->register_unknown_event( sub { 
        my ($ns, $localname) = @_;
        Ocean::Error::ProtocolError->throw(
            type    => Ocean::Constants::StreamErrorType::UNSUPPORTED_STANZA_TYPE,
            message =>
                sprintf(q{Unsupported stanza: %s:%s},
                    $ns || '', $localname || ''),
        );        
    } );
    return $handler;
}

sub _build_parser {
    my $self = shift;
    my $parser = XML::Parser::ExpatNB->new(
        Namespaces       => 1, 
        ProtocolEncoding => 'UTF-8',
    );
    $parser->setHandlers(
        Start => sub { $self->_start_element(@_) }, 
        Char  => sub { $self->_characters(@_)    },
        End   => sub { $self->_end_element(@_)   },
    );
    return $parser;
}

sub _start_element {
    my ($self, $expat, $localname, %attrs) = @_;
    try {
        my $ns    = $expat->namespace($localname);
        my $depth = $expat->depth;
        $self->[HANDLER]->start_element($ns, $localname, $depth, \%attrs);
    } catch {
        # XXX dont' throw to make sure RAII of XML::Parser
        $self->[DELEGATE]->on_client_event_error($_);
    };
}

sub _characters {
    my ($self, $expat, $text) = @_;
    try {
        $self->[HANDLER]->characters($text);
    } catch {
        # XXX dont' throw to make sure RAII of XML::Parser
        $self->[DELEGATE]->on_client_event_error($_);
    };
}

sub _end_element {
    my ($self, $expat, $localname) = @_;
    try {
        my $ns    = $expat->namespace($localname);
        my $depth = $expat->depth;
        $self->[HANDLER]->end_element($ns, $localname, $depth);
    } catch {
        # XXX dont' throw to make sure RAII of XML::Parser
        $self->[DELEGATE]->on_client_event_error($_);
    };
}

sub release {
    my $self = shift;
    $self->_release_parser();
    $self->_release_handler();
    $self->release_delegate();
}

1;

=head1 AUTHOR

Lyo Kato, E<lt>lyo.kato@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Lyo Kato

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

