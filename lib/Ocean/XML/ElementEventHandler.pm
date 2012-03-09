package Ocean::XML::ElementEventHandler;

use strict;
use warnings;

use Log::Minimal;
use Ocean::Error;
use Ocean::Constants::StreamErrorType;
use Ocean::XML::ElementBuffer;
use Ocean::Util::XML qw(gen_xml_sig);
use Ocean::XML::Namespaces qw(STREAM);

use constant {
    STREAM_EVENT     => 0,
    STANZA_EVENTS    => 1,
    UNKNOWN_EVENT    => 2,
    CURRENT_CALLBACK => 3,
    CURRENT_BUFFER   => 4,
};

sub new {
    my $class = shift;
    my $self = bless [
        sub {},  # STREAM_EVENT
        {},      # STANZA_EVENTS
        undef,   # UNKNOWN_EVENT
        undef,   # CURRENT_CALLBACK
        undef,   # CURRENT_BUFFER
    ], $class;
    return $self;
}

sub register_stream_event {
    my ($self, $callback) = @_;
    $self->[STREAM_EVENT] = $callback;
}

sub register_stanza_event {
    my ($self, $ns, $localname, $callback) = @_;
    unless ($ns && $localname) {
        debugf("<Stream> <Decoder> Failed to register stanza event. Namespace or local-name not found");
        Ocean::Error::ProtocolError->throw(
            type => Ocean::Constants::StreamErrorType::INVALID_XML);
    }
    my $sig = gen_xml_sig($localname, $ns);
    $self->[STANZA_EVENTS]->{$sig} = $callback;
}

sub register_unknown_event {
    my ($self, $callback) = @_;
    $self->[UNKNOWN_EVENT] = $callback;
}

sub start_element {
    my ($self, $ns, $localname, $depth, $attrs) = @_;
    if ($depth == 0) {
        Ocean::Error::ProtocolError->throw(
            message => q{xml root element should be 'stream'}, 
        ) unless ($ns eq STREAM && $localname eq 'stream');
        $self->[STREAM_EVENT]->($attrs);
    } else {
        unless ($ns && $localname) {
            debugf("<Stream> <Decoder> Namespace or local-name not found");
            Ocean::Error::ProtocolError->throw(
                type => Ocean::Constants::StreamErrorType::INVALID_XML);
        }
        if ($self->[CURRENT_BUFFER]) {
            $self->[CURRENT_BUFFER]->start_capturing(
                $ns, $localname, $depth, $attrs);
        } else {
            my $sig = gen_xml_sig($localname, $ns);
            if (exists $self->[STANZA_EVENTS]->{$sig}) {
                $self->[CURRENT_CALLBACK] = $self->[STANZA_EVENTS]->{$sig};
                $self->[CURRENT_BUFFER] = Ocean::XML::ElementBuffer->new(
                    $ns, $localname, $depth, $attrs);
            } else {
                $self->[UNKNOWN_EVENT]->($ns, $localname, $depth, $attrs)
                    if $self->[UNKNOWN_EVENT];
            }
        }
    }
}

sub characters {
    my ($self, $text) = @_;
    $self->[CURRENT_BUFFER]->push_text($text)
        if ($self->[CURRENT_BUFFER]);
}

sub end_element {
    my ($self, $ns, $localname, $depth) = @_;

    if ($self->[CURRENT_BUFFER]) {

        if ($self->[CURRENT_BUFFER]->match($ns, $localname, $depth)) {

            my $buffer   = $self->[CURRENT_BUFFER];
            my $callback = $self->[CURRENT_CALLBACK];

            $self->[CURRENT_BUFFER]   = undef;
            $self->[CURRENT_CALLBACK] = undef;

            $callback->($buffer->to_element());

        } elsif ($self->[CURRENT_BUFFER]->is_capturing($ns, $localname, $depth)) {
            $self->[CURRENT_BUFFER]->finish_capturing($ns, $localname, $depth);
        }
    }
}

sub release {
    my $self = shift;
    $self->[STREAM_EVENT] = undef;
    $self->[UNKNOWN_EVENT] = undef;
    $self->[STANZA_EVENTS] = {};
}

sub DESTROY {
    my $self = shift;
    $self->release();
}

1;
