package Ocean::Test::Spy::Server;

use strict;
use warnings;


sub new {
    my $class = shift;
    my $self = bless {
        _event_stack => [], 
    }, $class;
    return $self;
}

sub clear {
    my $self = shift;
    $self->{_event_stack} = [];
}

sub event_stack {
    my $self = shift;
    return $self->{_event_stack};
}

sub push_event {
    my ($self, $type, $data) = @_;
    push( @{ $self->{_event_stack} }, { type => $type, data => $data } );
}

sub get_last_event {
    my $self = shift;
    my $stack = $self->{_event_stack};
    my $length = scalar @$stack;
    $self->{_event_stack}->[$length - 1];
}

sub get_event_from_last {
    my ($self, $num) = @_;
    my $stack = $self->{_event_stack};
    my $length = scalar @$stack;
    $length -= $num;
    $self->{_event_stack}->[$length - 1];
}

sub get_event {
    my ($self, $depth) = @_;
    return $self->event_stack->[$depth];
}

sub on_stream_bound_jid {
    my ($self, $stream_id, $bound_jid) = @_;
    $self->push_event(bound_jid => { 
            stream_id => $stream_id, 
            bound_jid => $bound_jid, 
        });
}

sub on_stream_bound_closed {
    my ($self, $bound_jid) = @_;
    $self->push_event(bound_closed => { 
            bound_jid => $bound_jid,
        });
}
sub on_stream_unbound_closed {
    my ($self, $stream_id) = @_;
    $self->push_event(unbound_closed => {
            stream_id => $stream_id,
        });
}

sub on_stream_handle_message {
    my ($self, $bound_jid, $message) = @_;
    $self->push_event(message => {
        bound_jid => $bound_jid,
        to_jid    => $message->to,
        message   => $message,
        });
}

sub on_stream_handle_presence {
    my ($self, $bound_jid, $presence) = @_;
    $self->push_event(presence => {
        bound_jid => $bound_jid,
        presence  => $presence,
        });
}

sub on_stream_handle_initial_presence {
    my ($self, $bound_jid, $presence) = @_;
    $self->push_event(initial_presence => {
        bound_jid => $bound_jid,
        presence  => $presence,
        });
}

sub on_stream_handle_silent_disconnection {
    my ($self, $bound_jid) = @_;
    $self->push_event(silent_disconnection => {
        bound_jid => $bound_jid,
        });
}

sub on_stream_handle_unavailable_presence {
    my ($self, $bound_jid) = @_;
    $self->push_event(unavailable => {
        bound_jid => $bound_jid 
        });
}

sub on_stream_handle_sasl_auth {
    my ($self, $stream_id, $domain, $auth) = @_;
    $self->push_event(auth => {
        stream_id => $stream_id,
        domain    => $domain,
        auth      => $auth,
        });
}

sub on_stream_handle_bind_request {
    my ($self, $stream_id, $user_id, $domain) = @_;
    $self->push_event(bind_request => {
        user_id   => $user_id,
        stream_id => $stream_id,
        domain    => $domain,
        });
}

sub on_stream_handle_roster_request {
    my ($self, $bound_jid, $req) = @_;
    $self->push_event(roster_request => {
        bound_jid => $bound_jid,
        req       => $req,
        });
}

sub on_stream_handle_vcard_request {
    my ($self, $bound_jid, $req) = @_;
    $self->push_event(vcard_request => {
        bound_jid => $bound_jid,
        req       => $req,
        });
}

1;
