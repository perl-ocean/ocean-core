package Ocean::Cluster::Frontend::Handler::Room;

use strict;
use warnings;

use parent 'Ocean::Handler::Room';

use Ocean::Constants::EventType;

sub on_room_info_request {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::ROOM_INFO_REQUEST,
        {
            from => $args->from->as_string,
            id   => $args->id,
            room => $args->room,
        }
    );
}

sub on_room_list_request {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::ROOM_LIST_REQUEST,
        {
            from => $args->from->as_string,
            id   => $args->id,
        }
    );
}

sub on_room_members_list_request {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::ROOM_MEMBERS_LIST_REQUEST,
        {
            from => $args->from->as_string,
            id   => $args->id,
            room => $args->room,
        }
    );
}

sub on_room_invitation {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::ROOM_INVITATION,
        {
            from   => $args->from->as_string,
            to     => $args->to->as_string,
            room   => $args->room,
            reason => $args->reason,
            thread => $args->thread,
        }
    );
}
sub on_room_invitation_decline {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::ROOM_INVITATION_DECLINE,
        {
            from   => $args->from->as_string,
            to     => $args->to->as_string,
            room   => $args->room,
            reason => $args->reason,
            thread => $args->thread,
        }
    );
}
sub on_room_message {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::SEND_ROOM_MESSAGE,
        {
            from    => $args->from->as_string,
            room    => $args->room,
            body    => $args->body,
            subject => $args->subject,
            html    => $args->html,
        }
    );
}
sub on_room_presence {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::ROOM_PRESENCE,
        {
            from     => $args->from->as_string,
            room     => $args->room,
            nickname => $args->nickname,
            show     => $args->show,
            status   => $args->status,
        }
    );
}
sub on_leave_room_presence {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::LEAVE_ROOM_PRESENCE,
        {
            from     => $args->from->as_string,
            room     => $args->room,
            nickname => $args->nickname,
        }
    );
}
sub on_toward_room_member_iq {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::SEND_IQ_TOWARD_ROOM_MEMBER,
        {
            id       => $args->id,
            type     => $args->type,
            room     => $args->room,
            nickname => $args->nickname,
            from     => $args->from->as_string,
            raw      => $args->raw,
        }
    );
}

1;
__END__
