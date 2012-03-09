package Ocean::Standalone::Handler::Room;

use strict;
use warnings;

use parent 'Ocean::Handler::Room';

use Ocean::Config;
use Ocean::Constants::RoomPresenceStatus;
use Ocean::JID;
use Ocean::Stanza::DeliveryRequestBuilder::MessageError;
use Ocean::Stanza::DeliveryRequestBuilder::PresenceError;
use Ocean::Stanza::DeliveryRequestBuilder::IQError;
use Ocean::Stanza::DeliveryRequestBuilder::RoomInfo;
use Ocean::Stanza::DeliveryRequestBuilder::RoomList;
use Ocean::Stanza::DeliveryRequestBuilder::RoomListItem;
use Ocean::Stanza::DeliveryRequestBuilder::RoomMembersList;
use Ocean::Stanza::DeliveryRequestBuilder::RoomMembersListItem;
use Ocean::Stanza::DeliveryRequestBuilder::RoomInvitation;
use Ocean::Stanza::DeliveryRequestBuilder::RoomInvitationDecline;
use Ocean::Stanza::DeliveryRequestBuilder::Presence;
use Ocean::Stanza::DeliveryRequestBuilder::RoomMessage;
use Ocean::Stanza::DeliveryRequestBuilder::UnavailablePresence;
use Ocean::Stanza::DeliveryRequestBuilder::TowardRoomMemberIQ;

sub on_room_info_request {
    my ($self, $ctx, $args) = @_;

    my $request_id = $args->id;
    my $sender_jid = $args->from;
    my $room_name  = $args->room;

    my $room = $ctx->get('db')->find_room_by_name($room_name);
    unless ($room) {
        # XXX should throw error?
        return;
    }

    my $member = 
        $ctx->get('db')->find_room_member_by_room_id_and_username(
            $room->id, $sender_jid->node);

    unless ($member) {
        # XXX deliver error: not allowed to access this room
        return;
    }

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::RoomInfo->new;
    $builder->request_id($request_id);
    $builder->to($sender_jid);
    $builder->room_name($room_name);
    $builder->room_nickname($room->nickname || $room_name);
    $ctx->deliver($builder->build());
}

sub on_room_list_request {
    my ($self, $ctx, $args) = @_;

    my $request_id = $args->id;
    my $sender_jid = $args->from;

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::RoomList->new;
    $builder->request_id($request_id);
    $builder->to($sender_jid);

    my @rooms = 
        $ctx->get('db')->search_belonging_rooms_by_username($sender_jid->node);

    for my $room ( @rooms ) {
        my $item = Ocean::Stanza::DeliveryRequestBuilder::RoomListItem->new;
        $item->room_name($room->name);
        $item->room_nickname($room->nickname);
        $builder->add_item_builder($item);
    }

    $ctx->deliver($builder->build());
}

sub on_room_members_list_request {
    my ($self, $ctx, $args) = @_;

    my $request_id = $args->id;
    my $sender_jid = $args->from;
    my $room_name  = $args->room;

    my $room = $ctx->get('db')->find_room_by_name($room_name);
    unless ($room) {
        # XXX should throw error?
        return;
    }

    my $muc_domain = 
        Ocean::Config->instance->get(muc => q{domain});

    my $member = 
        $ctx->get('db')->find_room_member_by_room_id_and_username(
            $room->id, $sender_jid->node);

    unless ($member) {
        # XXX deliver error: not allowed to access this room
        return;
    }

    my @member_connections = 
        $ctx->get('db')->search_room_member_connection_by_room_id($room->id);

    my @members = 
        map { +{ 
            conn     => $ctx->get('db')->find_connection_by_id($_->connection_id),
            room_jid => Ocean::JID->build($room_name, $muc_domain, $_->nickname),
            } } 
        @member_connections;

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::RoomMembersList->new;
    $builder->request_id($request_id);
    $builder->to($sender_jid);
    $builder->room($room_name);

    for my $member ( @members ) {
        my $item = 
            Ocean::Stanza::DeliveryRequestBuilder::RoomMembersListItem->new;
        $item->jid($member->{room_jid});
        my $user = $ctx->get('db')->find_user_by_username($member->{conn}->username);
        $item->name($user->nickname);
        $builder->add_item_builder($item);
    }

    $ctx->deliver($builder->build());
}

sub on_room_invitation {
    my ($self, $ctx, $args) = @_;

    my $sender_jid   = $args->from;
    my $room_name    = $args->room;
    my $receiver_jid = $args->to;
    my $reason       = $args->reason;
    my $thread       = $args->thread;

    my $room = $ctx->get('db')->find_room_by_name($room_name);
    unless ($room) {

        # XXX error?

        #$room = $ctx->get('db')->insert_room(
        #    name => $room_name, 
        #);

        ## TODO check max room limit per user

        #$ctx->get('db')->insert_room_member(
        #    room_id  => $room->id,
        #    username => $sender_jid->node,
        #);

        return;
    }

    my $member = 
        $ctx->get('db')->find_room_member_by_room_id_and_username(
            $room->id, $sender_jid->node);

    unless ($member) {
        # XXX deliver error: not allowed to acess this room
        return;
    }

    my $receiver =
        $ctx->get('db')->find_room_member_by_room_id_and_username(
            $room->id, $receiver_jid->node);

    unless ($receiver) {

        $receiver = $ctx->get('db')->insert_room_member(
            room_id  => $room->id,
            username => $receiver_jid->node,
        );

    }

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::RoomInvitation->new;
    $builder->room($room->name);
    $builder->from($sender_jid);
    $builder->to($receiver_jid);
    $builder->reason($reason);
    $builder->thread($thread);
    $ctx->deliver($builder->build());
}

sub on_room_invitation_decline {
    my ($self, $ctx, $args) = @_;

    my $sender_jid   = $args->from;
    my $room_name    = $args->room;
    my $receiver_jid = $args->to;
    my $reason       = $args->reason;
    my $thread       = $args->thread;

    my $room = $ctx->get('db')->find_room_by_name($room_name);
    unless ($room) {
        # XXX do nothing?
        return;
    }

    my $member = 
        $ctx->get('db')->find_room_member_by_room_id_and_username(
            $room->id, $sender_jid->node);

    unless ($member) {
        # XXX deliver error: not allowed to acess this room
        return;
    }

    $member->delete();

    my $receiver =
        $ctx->get('db')->find_room_member_by_room_id_and_username(
            $room->id, $receiver_jid->node);

    unless ($receiver) {
        # do nothing?
        return;
    }

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::RoomInvitationDecline->new;
    $builder->room($room->name);
    $builder->from($sender_jid);
    $builder->from($receiver_jid);
    $builder->reason($reason);
    $builder->thread($thread);
    $ctx->deliver($builder->build());
}

sub on_room_message {
    my ($self, $ctx, $args) = @_;

    my $sender_jid = $args->from;
    my $room_name  = $args->room;
    my $body       = $args->body;
    my $html       = $args->html;
    my $subject    = $args->subject;

    my $muc_domain = 
        Ocean::Config->instance->get(muc => q{domain});

    my $room = $ctx->get('db')->find_room_by_name($room_name);

    unless ($room) {
        # TODO write error class which wrap MessageError
        my $builder = Ocean::Stanza::DeliveryRequestBuilder::MessageError->new;
        $builder->from(Ocean::JID->build($room_name, $muc_domain));
        $builder->to($sender_jid);
        $builder->body($body);
        $builder->error_type('auth');
        $builder->error_reason('item-not-found');
        $ctx->deliver($builder->build());
        return;
    }

    my $member = 
        $ctx->get('db')->find_room_member_by_room_id_and_username(
            $room->id, $sender_jid->node);

    unless ($member) {
        # TODO write error class which wrap MessageError
        my $builder = Ocean::Stanza::DeliveryRequestBuilder::MessageError->new;
        $builder->from(Ocean::JID->build($room_name, $muc_domain));
        $builder->to($sender_jid);
        $builder->body($body);
        $builder->error_type('auth');
        $builder->error_reason('not-acceptable');
        $ctx->deliver($builder->build());
        return;
    }

    $room->update({
        subject => $subject,     
    }) if $subject;

    my $sender_connection = 
        $ctx->get('db')->find_connection_by_jid($sender_jid);

    my $sender_member_connection = 
        $ctx->get('db')->find_room_member_connection_by_room_id_and_connection_id(
            $room->id, $sender_connection->id);

    my $nickname = $sender_member_connection->nickname;

    my @member_connections = 
        $ctx->get('db')->search_room_member_connection_by_room_id($room->id);

    my $sender_room_jid = 
        Ocean::JID->build($room_name, $muc_domain, $nickname);

    my @members = 
        map { +{ 
            conn     => $ctx->get('db')->find_connection_by_id($_->connection_id),
            #room_jid => Ocean::JID->build($room_name, $muc_domain, $_->nickname),
            } } 
        @member_connections;

    # broadcast
    for my $member ( @members ) { 
        my $builder = Ocean::Stanza::DeliveryRequestBuilder::RoomMessage->new;
        $builder->from($sender_room_jid);
        my $to_jid = Ocean::JID->build(
            $member->{conn}->username, 
            Ocean::Config->instance->get(server => q{domain}),
            $member->{conn}->resource,
        );
        $builder->to($to_jid);
        $builder->body($body);
        $builder->html($html);
        $builder->subject($subject);
        $ctx->deliver($builder->build());
    }
}

sub on_room_presence {
    my ($self, $ctx, $args) = @_;

    $self->log_debug('on_room_presence');

    my $sender_jid = $args->from;
    my $room_name  = $args->room;
    my $nickname   = $args->nickname;

    my $muc_domain = 
        Ocean::Config->instance->get(muc => q{domain});

    my $room = $ctx->get('db')->find_room_by_name($room_name);

    my $new_room_created = 0;

    unless ($room) {

        $self->log_debug('room not found: %s', $room_name);
        $self->log_debug('create new room');

        $room = $ctx->get('db')->insert_room(
            name => $room_name, 
        );

        # TODO check max room limit per user
        # if ($self->reach_max_room_limit_per_user) {
        #     # TODO write new class which wrap PresenceError
        #     my $builder = Ocean::Stanza::DeliveryRequestBuilder::PresenceError->new;
        #     $builder->is_for_room(1);
        #     $builder->from(Ocean::JID->build($room_name, $muc_domain));
        #     $builder->to($sender_jid);
        #     $builder->error_type('cancel');
        #     $builder->error_reason('not-allowed');
        #     $ctx->deliver($builder->build());
        #     return;
        # }

        $ctx->get('db')->insert_room_member(
            room_id  => $room->id,
            username => $sender_jid->node,
        );

        $new_room_created = 1;
    }

    my $member = 
        $ctx->get('db')->find_room_member_by_room_id_and_username(
            $room->id, $sender_jid->node);

    unless ($member) {

        # XXX deliver error: not allowed to access this room
        $self->log_debug('user not allowed to access this room');

        # TODO write new class which wrap PresenceError
        my $builder = Ocean::Stanza::DeliveryRequestBuilder::PresenceError->new;
        $builder->is_for_room(1);
        $builder->from(Ocean::JID->build($room_name, $muc_domain));
        $builder->to($sender_jid);
        $builder->error_type('auth');
        $builder->error_reason('forbidden'); # or 'registration-required'
        $ctx->deliver($builder->build());
        return;
    }

    my $member_connection = 
        $ctx->get('db')->find_room_member_connection_by_room_id_and_nickname(
            $room->id, $nickname);

    my $connection = $ctx->get('db')->find_connection_by_jid($sender_jid);

    my $sender = $ctx->get('db')->find_user_by_username( $connection->username );


    if (     $member_connection 
        && !($member_connection->connection_id == $connection->id)) # myself
    {

        $self->log_debug('nickname already used');

        # TODO write new class which wrap PresenceError
        my $builder = Ocean::Stanza::DeliveryRequestBuilder::PresenceError->new;
        $builder->is_for_room(1);
        $builder->from(Ocean::JID->build($room_name, $muc_domain));
        $builder->to($sender_jid);
        $builder->error_type('cancel');
        $builder->error_reason('conflict'); # or 'not-acceptable'
        $ctx->deliver($builder->build());
        return;
    }

    # TODO validate nickname

    my @member_connections = 
        $ctx->get('db')->search_room_member_connection_by_room_id($room->id);

    # TODO check max room limit per room
    # if ( Ocean::Config->instance->get(muc => q{max_occupants_per_room}) < $member_connections->room_count ) {
    #     my $builder = Ocean::Stanza::DeliveryRequestBuilder::PresenceError->new;
    #     $builder->is_for_room(1);
    #     $builder->from(Ocean::JID->build($room_name, $muc_domain));
    #     $builder->to($sender_jid);
    #     $builder->error_type('wait');
    #     $builder->error_reason('service-unavailable');
    #     $ctx->deliver($builder->build());
    #     return;
    # }

    $ctx->get('db')->insert_room_member_connection(
        room_id       => $room->id, 
        nickname      => $nickname,
        connection_id => $connection->id,
    );

    my $sender_room_jid = 
        Ocean::JID->build($room_name, $muc_domain, $nickname);

    my @members = 
        map { +{ 
            conn => $ctx->get('db')->find_connection_by_id($_->connection_id),
            room_jid => Ocean::JID->build($room_name, $muc_domain, $_->nickname),
            } } 
        @member_connections;

    # broadcast
    for my $member ( @members ) { 
        my $builder = Ocean::Stanza::DeliveryRequestBuilder::Presence->new;
        $builder->is_for_room(1);
        $builder->from($sender_room_jid);
        my $to_jid = Ocean::JID->build(
            $member->{conn}->username, 
            Ocean::Config->instance->get(server => q{domain}),
            $member->{conn}->resource,
        );
        $builder->to($to_jid);
        $builder->raw_jid($sender_jid);
        $builder->image_hash($sender->profile_img_hash)
            if $sender->profile_img_hash;
        # $builder->show($args->show);
        # $builder->status($args->status);
        $ctx->deliver($builder->build());
    }

    # probe
    for my $member ( @members ) { 
        my $builder = Ocean::Stanza::DeliveryRequestBuilder::Presence->new;
        $builder->is_for_room(1);
        $builder->from($member->{room_jid});
        $builder->to($sender_jid);
        my $raw_jid = Ocean::JID->build(
            $member->{conn}->username, 
            Ocean::Config->instance->get(server => q{domain}),
            $member->{conn}->resource,
        );
        $builder->raw_jid($raw_jid);
        # TODO handle show/status
        my $user = $ctx->get('db')->find_user_by_username($member->{conn}->username);
        $builder->image_hash($user->profile_img_hash)
            if $user->profile_img_hash;
        $ctx->deliver($builder->build());
    }

    # Ack should be last
    my $builder = Ocean::Stanza::DeliveryRequestBuilder::Presence->new;
    $builder->is_for_room(1);
    $builder->from($sender_room_jid);
    $builder->to($sender_jid);
    $builder->raw_jid($sender_jid);
    $builder->add_room_status(
        Ocean::Constants::RoomPresenceStatus::SELF_PRESENCE);
    $builder->add_room_status(
        Ocean::Constants::RoomPresenceStatus::ROOM_CREATED)
            if $new_room_created;
    my $user = $ctx->get('db')->find_user_by_username($sender_jid->node);
    # $builder->show($args->show);
    # $builder->status($args->status);
    $builder->image_hash($user->profile_img_hash)
        if $user->profile_img_hash;
    $ctx->deliver($builder->build());

}

sub on_leave_room_presence {
    my ($self, $ctx, $args) = @_;

    my $sender_jid = $args->from;
    my $room_name  = $args->room;
    my $nickname   = $args->nickname;

    my $room = $ctx->get('db')->find_room_by_name($room_name);
    unless ($room) {
        # XXX deliver error: room not found,  or do nothing?
        return;
    }

    my $member_connection = 
        $ctx->get('db')->find_room_member_connection_by_room_id_and_nickname(
            $room->id, $nickname);

    unless ($member_connection) {
        # XXX deliver error: nickname not used,  or do nothing?
        return;
    }

    # XXX should delete member? or required unavailable ack?
    $member_connection->delete();

    my $connection = $ctx->get('db')->find_connection_by_jid($sender_jid);

    my @member_connections = 
        $ctx->get('db')->search_room_member_connection_by_room_id($room->id);

    my $muc_domain = 
        Ocean::Config->instance->get(muc => q{domain});

    my $sender_room_jid = 
        Ocean::JID->build($room_name, $muc_domain, $nickname);

    my @members = 
        map { +{ 
            conn => $ctx->get('db')->find_connection_by_id($_->connection_id),
            room_jid => Ocean::JID->build($room_name, $muc_domain, $_->nickname),
            } } 
        @member_connections;

    # broadcast
    for my $member ( @members ) { 
        my $builder = Ocean::Stanza::DeliveryRequestBuilder::UnavailablePresence->new;
        # $builder->is_for_room(1);
        $builder->from($sender_room_jid);
        my $to_jid = Ocean::JID->build(
            $member->{conn}->username, 
            Ocean::Config->instance->get(server => q{domain}),
            $member->{conn}->resource,
        );
        $builder->to($to_jid);
        $ctx->deliver($builder->build());
    }
}

sub on_toward_room_member_iq {
    my ($self, $ctx, $args) = @_;

    my $sender_jid = $args->from;
    my $room_name  = $args->room;
    my $nickname   = $args->nickname;

    my $muc_domain = 
        Ocean::Config->instance->get(muc => q{domain});

    my $room = $ctx->get('db')->find_room_by_name($room_name);
    unless ($room) {
        # XXX deliver error: room not found,  or do nothing?
        return;
    }

    my $sender_connection = 
        $ctx->get('db')->find_connection_by_jid($sender_jid);

    my $sender_member_connection = 
        $ctx->get('db')->find_room_member_connection_by_room_id_and_connection_id(
            $room->id, $sender_connection->id);

    my $sender_nickname = $sender_member_connection->nickname;

    # XXX OK?
    return if $sender_nickname eq $nickname;

    my $member_connection = 
        $ctx->get('db')->find_room_member_connection_by_room_id_and_nickname(
            $room->id, $nickname);

    unless ($member_connection) {
        # XXX deliver error: user not found,  or do nothing?
        return;
    }

    my $connection = $ctx->get('db')->find_connection_by_id(
        $member_connection->connection_id);

    unless ($connection) {
        # must not come here
        $self->log_warn('connection not found');
        return;
    }

    my $receiver_jid = Ocean::JID->build(
        $connection->username, 
        Ocean::Config->instance->get(server => q{domain}),
        $connection->resource,
    );


    my $sender_room_jid = 
        Ocean::JID->build($room_name, $muc_domain, $sender_nickname);

    ## XXX check relation?

    my $receiver = 
        $ctx->get('db')->find_user_by_username($receiver_jid->node);
    return unless $receiver;

    unless ($receiver->is_echo) {

        my $builder = 
            Ocean::Stanza::DeliveryRequestBuilder::TowardRoomMemberIQ->new;
        $builder->to($receiver_jid);
        $builder->from($sender_room_jid);
        $builder->query_type($args->type);
        $builder->request_id($args->id);
        $builder->raw($args->raw);
        $ctx->deliver($builder->build());
    }
}

1;
