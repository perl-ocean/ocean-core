package Ocean::Context;

use strict;
use warnings;

use Ocean::Registrar::DeliveryInfo;
use Ocean::Config;

use Ocean::Stanza::DeliveryRequest::BoundJID;
use Ocean::Stanza::DeliveryRequest::ChatMessage;
use Ocean::Stanza::DeliveryRequest::DiscoInfo;
use Ocean::Stanza::DeliveryRequest::DiscoInfoIdentity;
use Ocean::Stanza::DeliveryRequest::HTTPAuthCompletion;
use Ocean::Stanza::DeliveryRequest::HTTPAuthFailure;
use Ocean::Stanza::DeliveryRequest::Presence;
use Ocean::Stanza::DeliveryRequest::PubSubEvent;
use Ocean::Stanza::DeliveryRequest::PubSubEventItem;
use Ocean::Stanza::DeliveryRequest::Roster;
use Ocean::Stanza::DeliveryRequest::RosterItem;
use Ocean::Stanza::DeliveryRequest::RosterPush;
use Ocean::Stanza::DeliveryRequest::SASLAuthCompletion;
use Ocean::Stanza::DeliveryRequest::SASLAuthFailure;
use Ocean::Stanza::DeliveryRequest::SASLPassword;
use Ocean::Stanza::DeliveryRequest::UnavailablePresence;
use Ocean::Stanza::DeliveryRequest::vCard;
use Ocean::Stanza::DeliveryRequest::RoomInvitation;
use Ocean::Stanza::DeliveryRequest::RoomInvitationDecline;
use Ocean::Stanza::DeliveryRequest::TowardUserIQ;
use Ocean::Stanza::DeliveryRequest::JingleInfo;
use Ocean::Stanza::DeliveryRequest::MessageError;
use Ocean::Stanza::DeliveryRequest::PresenceError;
use Ocean::Stanza::DeliveryRequest::IQError;

use Log::Minimal;
use Try::Tiny;

sub new {
    my $class = shift;
    my $self = bless {
        _stash    => {}, 
        _delegate => undef,
    }, $class;
    return $self;
}

sub config {
    my ($self, $field) = @_;
    return Ocean::Config->instance->get(handler => $field);
}

sub log_debug { 
    my $self     = shift;
    my $template = shift;
    debugf('<Server> <Context> ' . $template, @_);
}

sub log_info { 
    my $self     = shift;
    my $template = shift;
    infof('<Server> <Context> ' . $template, @_);
}

sub log_warn { 
    my $self     = shift;
    my $template = shift;
    warnf('<Server> <Context> ' . $template, @_);
}

sub log_crit { 
    my $self     = shift;
    my $template = shift;
    critff('<Server> <Context> ' . $template, @_);
}


sub set_delegate {
    my ($self, $delegate) = @_;
    $self->{_delegate} = $delegate;
}

sub initialize {
    my $self = shift;
    # template method
}

sub finalize {
    my $self = shift;
    # template method
}

sub release {
    my $self = shift;
    delete $self->{_delegate}
        if $self->{_delegate};
}

sub set {
    my ($self, $key, $value) = @_;
    $self->{_stash}{$key} = $value;
}

sub get {
    my ($self, $key) = @_;
    return $self->{_stash}{$key};
}

sub _get_delivery_info {
    my ($self, $event_type) = @_;
    return Ocean::Registrar::DeliveryInfo->get($event_type);
}

sub deliver {
    my ($self, $req) = @_;

    my $info = $self->_get_delivery_info($req->type);

    my $delivery_method = $info->{method};
    my $stanza_class    = $info->{class};

    unless ($delivery_method) {
        $self->log_crit("unknown deliver request type: %s", $req->type);
        return;
    }

    if ($self->{_delegate}->can($delivery_method)) {
        try {
            my $stanza = $stanza_class->new($req->args);
            $self->{_delegate}->$delivery_method($stanza);
        } catch {
            $self->log_crit("failed to deliver stanza: %s", $_);
        };
    } else {
        $self->log_crit("method not found '%s'", $delivery_method);
    }
}

1;
