package Ocean::Cluster::Backend::Handler::Room;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::NodeEventHandler';

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
} }

sub on_room_list_request {
    my ($self, $ctx, $node_id, $args) = @_;
    $self->log_warn('on_room_list_request not implemented');
}

sub on_room_info_request {
    my ($self, $ctx, $node_id, $args) = @_;
    $self->log_warn('on_room_list_request not implemented');
}

sub on_room_members_request {
    my ($self, $ctx, $node_id, $args) = @_;
    $self->log_warn('on_room_members_request not implemented');
}

sub on_new_room {
    my ($self, $ctx, $node_id, $args) = @_;
    $self->log_warn('on_new_room not implemented');
}

sub on_enter_room {
    my ($self, $ctx, $node_id, $args) = @_;
    $self->log_warn('on_enter_room not implemented');
}

sub on_room_message {
    my ($self, $ctx, $node_id, $args) = @_;
    $self->log_warn('on_room_message not implemented');
}

sub on_leave_room {
    my ($self, $ctx, $node_id, $args) = @_;
    $self->log_warn('on_leave_room not implemented');
}

1;
