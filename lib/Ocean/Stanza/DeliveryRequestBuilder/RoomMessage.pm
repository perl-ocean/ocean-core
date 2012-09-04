package Ocean::Stanza::DeliveryRequestBuilder::RoomMessage;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::DELIVER_ROOM_MESSAGE }

sub to {
    my ($self, $to_jid) = @_;
    $self->{_to} = "$to_jid";
    return $self;
}

sub from {
    my ($self, $from_jid) = @_;
    $self->{_from} = "$from_jid";
    return $self;
}

sub body {
    my ($self, $body) = @_;
    $self->{_body} = $body;
    return $self;
}

sub html {
    my ($self, $html) = @_;
    $self->{_html} = $html;
    return $self;
}

sub subject {
    my ($self, $subject) = @_;
    $self->{_subject} = $subject;
    return $self;
}

sub thread {
    my ($self, $thread) = @_;
    $self->{_thread} = $thread;
    return $self;
}

sub state {
    my ($self, $state) = @_;
    $self->{_state} = $state;
    return $self;
}

sub build_args {
    my $self = shift;

    my $args = {};

    Ocean::Error::ParamNotFound->throw(
        message => q{'to' not found}, 
    ) unless exists $self->{_to};

    $args->{to} = $self->{_to};

    Ocean::Error::ParamNotFound->throw(
        message => q{'from' not found}, 
    ) unless exists $self->{_from};

    $args->{from}    = $self->{_from};
    $args->{type}    = 'groupchat';
    $args->{body}    = $self->{_body}   || '';
    $args->{html}    = $self->{_html}   || '';
    $args->{subject} = $self->{_subject} || '';
    $args->{thread}  = $self->{_thread} || '';
    $args->{state}   = $self->{_state}  || '';

    return $args;
}

1;
