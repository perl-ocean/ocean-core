package Ocean::Handler::Room;

use strict;
use warnings;

use parent 'Ocean::Handler';

use Ocean::Error;
use Ocean::Constants::EventType;

use Log::Minimal;

sub log_debug {
    my $self     = shift;
    my $template = shift;
    debugf('<Handler::Room> ' . $template, @_);
}

sub log_info {
    my $self     = shift;
    my $template = shift;
    infof('<Handler::Room> ' . $template, @_);
}

sub log_warn {
    my $self     = shift;
    my $template = shift;
    warnf('<Handler::Room> ' . $template, @_);
}

sub log_crit {
    my $self     = shift;
    my $template = shift;
    critf('<Handler::Room> ' . $template, @_);
}

sub event_method_map { +{
    Ocean::Constants::EventType::ROOM_INFO_REQUEST, 
        'on_room_info_request',
    Ocean::Constants::EventType::ROOM_LIST_REQUEST, 
        'on_room_list_request',
    Ocean::Constants::EventType::ROOM_MEMBERS_LIST_REQUEST, 
        'on_room_members_list_request',
    Ocean::Constants::EventType::ROOM_INVITATION, 
        'on_room_invitation',
    Ocean::Constants::EventType::ROOM_INVITATION_DECLINE, 
        'on_room_invitation_decline',
    Ocean::Constants::EventType::SEND_ROOM_MESSAGE, 
        'on_room_message',
    Ocean::Constants::EventType::ROOM_PRESENCE, 
        'on_room_presence',
    Ocean::Constants::EventType::LEAVE_ROOM_PRESENCE, 
        'on_leave_room_presence',
    Ocean::Constants::EventType::SEND_IQ_TOWARD_ROOM_MEMBER, 
        'on_toward_room_member_iq',
} }

sub on_room_info_request {
    my ($self, $ctx, $args) = @_;
    $self->log_warn('on_room_info_request not implemented');
}

sub on_room_list_request {
    my ($self, $ctx, $args) = @_;
    $self->log_warn('on_room_list_request not implemented');
}

sub on_room_members_list_request {
    my ($self, $ctx, $args) = @_;
    $self->log_warn('on_room_members_list_request not implemented');
}

sub on_room_invitation {
    my ($self, $ctx, $args) = @_;
    $self->log_warn('on_room_invitation not implemented');
}

sub on_room_invitation_decline {
    my ($self, $ctx, $args) = @_;
    $self->log_warn('on_room_invitation_decline not implemented');
}

sub on_room_message {
    my ($self, $ctx, $args) = @_;
    $self->log_warn('on_room_message not implemented');
}

sub on_room_presence {
    my ($self, $ctx, $args) = @_;
    $self->log_warn('on_room_presence not implemented');
}

sub on_leave_room_presence {
    my ($self, $ctx, $args) = @_;
    $self->log_warn('on_leave_room_presence not implemented');
}

sub on_toward_room_member_iq {
    my ($self, $ctx, $args) = @_;
    $self->log_warn('on_toward_room_member_iq not implemented');
}

1;
