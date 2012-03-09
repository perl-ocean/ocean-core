package Ocean::Test::Spy::StreamComponent::IO;

use strict;
use warnings;

sub new { bless {}, $_[0] }

sub clear {
    my $self = shift;
    for my $key (keys %$self) {
        delete $self->{$key};
    }
};

sub on_client_event_error {
    my ($self, $error) = @_;
    $self->{error} = $error;
}

sub on_received_stream {
    my ($self, $attrs) = @_;
    $self->{stream_attrs} = $attrs;
}

sub on_received_message {
    my ($self, $message) = @_;
    $self->{message_to_jid} = $message->to;
    $self->{message} = $message;
}

sub on_received_presence {
    my ($self, $presence) = @_;
    $self->{presence} = $presence;
}

sub on_received_unavailable_presence {
    my $self = shift;
    $self->{unavailable_presence} = 1;
}

sub on_received_bind_request {
    my ($self, $req) = @_;
    $self->{bind_request} = $req;
}

sub on_received_session_request {
    my ($self, $req) = @_;
    $self->{session_request} = $req;
}

sub on_received_roster_request {
    my ($self, $req) = @_;
    $self->{roster_request} = $req;
}

sub on_received_ping {
    my ($self, $ping) = @_;
    $self->{ping} = $ping;
}

sub on_received_vcard_request {
    my ($self, $req) = @_;
    $self->{vcard_request} = $req;
}

1;
