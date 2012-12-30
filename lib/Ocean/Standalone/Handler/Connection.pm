package Ocean::Standalone::Handler::Connection;

use strict;
use warnings;

use parent 'Ocean::Handler::Connection';

use Ocean::JID;
use Ocean::Error;

use Ocean::Stanza::DeliveryRequestBuilder::BoundJID;
use Ocean::Stanza::DeliveryRequestBuilder::Presence;
use Ocean::Stanza::DeliveryRequestBuilder::UnavailablePresence;

sub on_bind_request {
    my ($self, $ctx, $args) = @_;

    my $stream_id = $args->stream_id;
    my $user_id   = $args->user_id;

    $self->log_debug("on_bind_request");

    my $user = $ctx->get('db')->find_user_by_id($user_id);
    unless ($user) {
        $self->log_debug("user not found");
        # ignore?
        # throw error?
        return;
    }

    #my $resource = $args->resource || sha1_hex( gen_random(32) );
    my $resource = $args->resource;
    unless ($resource) {
        Ocean::Error::ProtocolError->throw(
            message => q{resource not found}, 
        );
    }

    my $jid = Ocean::JID->build(
        $user->username, 
        $args->domain,
        $resource,
    );

    $ctx->get('db')->insert_connection(
        user_id  => $user->user_id,
        username => $user->username,
        resource => $resource,
        domain   => $args->domain,
        #presence => undef,
    );

    my $builder = 
        Ocean::Stanza::DeliveryRequestBuilder::BoundJID->new;
    $builder->stream_id($stream_id);
    $builder->jid($jid);
    if ($args->want_extval) {
        $builder->nickname($user->nickname);
        $builder->photo_url($user->profile_img_url || '');
    }
    $ctx->deliver($builder->build());
}

sub on_presence {
    my ($self, $ctx, $args) = @_;

    my $sender_jid = $args->from;

    my $sender = $ctx->get('db')->find_user_by_username( $sender_jid->node );

    my $sender_conn = $ctx->get('db')->find_connection_by_jid( $sender_jid );
    #$sender_conn->presence_show( $args->show );
    #$sender_conn->presence_status( $args->status );
    $sender_conn->update({ 
        presence_show   => $args->show,
        presence_status => $args->status,
    });

    my @followers = $ctx->get('db')->search_followers_of($sender);

    for my $follower_id ( @followers ) {

        my @follower_conns = 
            $ctx->get('db')->search_available_connection_by_user_id($follower_id);

        for my $follower_conn ( @follower_conns ) {

            my $receiver_jid = Ocean::JID->build(
                $follower_conn->username,
                $follower_conn->domain,
                $follower_conn->resource,
            );

            my $builder =
                Ocean::Stanza::DeliveryRequestBuilder::Presence->new;
            $builder->from($sender_jid);
            $builder->to($receiver_jid);
            $builder->show($args->show);
            $builder->status($args->status);
            $builder->image_hash($sender->profile_img_hash)
                if $sender->profile_img_hash;

            $ctx->deliver($builder->build());

        }

    }
}

sub on_initial_presence {
    my ($self, $ctx, $args) = @_;

    my $sender_jid = $args->from;
    my $no_probe   = $args->no_probe;

    $self->log_debug("on_initial_presence");

    my $sender = $ctx->get('db')->find_user_by_username( $sender_jid->node );

    # UPDATE CONNECTION STATE
    my $sender_conn = $ctx->get('db')->find_connection_by_jid( $sender_jid );
    unless ($sender_conn) {
        $self->log_warn("connection for sender_jid %s not found", $sender_jid->as_string);
        return;
    }
    #$sender_conn->presence_show( $args->show );
    #$sender_conn->presence_status( $args->status );
    $sender_conn->update({ 
        presence_show   => $args->show,
        presence_status => $args->status,
    });

    $self->log_debug("broadcast presence");

    # send presence to follower
    my @followers = $ctx->get('db')->search_followers_of($sender);

    for my $follower_id ( @followers ) {

        my @follower_conns = 
            $ctx->get('db')->search_available_connection_by_user_id($follower_id);

        for my $follower_conn ( @follower_conns ) {

            my $receiver_jid = Ocean::JID->build(
                $follower_conn->username,
                $follower_conn->domain,
                $follower_conn->resource,
            );

            $self->log_debug("deliver presence to %s", 
                $receiver_jid->as_string);

            my $builder =
                Ocean::Stanza::DeliveryRequestBuilder::Presence->new;
            $builder->from($sender_jid);
            $builder->to($receiver_jid);
            $builder->show($args->show);
            $builder->status($args->status);
            $builder->image_hash($sender->profile_img_hash)
                if $sender->profile_img_hash;

            $ctx->deliver($builder->build());

        }

    }

    return if $no_probe;

    $self->log_debug("probe presence");

    my @followees = $ctx->get('db')->search_followees_of($sender);

    for my $followee_id ( @followees ) {

        my @followee_conns = 
            $ctx->get('db')->search_available_connection_by_user_id($followee_id);

        for my $followee_conn ( @followee_conns ) {

            my $followee_presence = $followee_conn->presence;

            my $followee_jid = Ocean::JID->build(
                  $followee_conn->username,
                  $followee_conn->domain,
                  $followee_conn->resource,
            );

            my $followee = $ctx->get('db')->find_user_by_username( $followee_jid->node );

            my $builder = 
                Ocean::Stanza::DeliveryRequestBuilder::Presence->new;
            $builder->from($followee_jid);
            $builder->to($sender_jid);
            $builder->show($followee_presence->show);
            $builder->status($followee_presence->status);
            $builder->image_hash($followee->profile_img_hash)
                if $followee->profile_img_hash;

            $ctx->deliver($builder->build());

        }

    }
}

sub on_silent_disconnection {
    my ($self, $ctx, $args) = @_;

    my $sender_jid = $args->from;

    my $sender = $ctx->get('db')->find_user_by_username( $sender_jid->node );

    my $sender_conn = $ctx->get('db')->find_connection_by_jid( $sender_jid );
    $sender_conn->delete() if $sender_conn;
}

sub on_unavailable_presence {
    my ($self, $ctx, $args) = @_;

    my $sender_jid = $args->from;

    my $sender = $ctx->get('db')->find_user_by_username( $sender_jid->node );

    my $sender_conn = $ctx->get('db')->find_connection_by_jid( $sender_jid );
    $sender_conn->delete() if $sender_conn;

    # send presence to follower
    my @followers = $ctx->get('db')->search_followers_of($sender);

    for my $follower_id ( @followers ) {

        my @follower_conns = 
            $ctx->get('db')->search_available_connection_by_user_id($follower_id);

        for my $follower_conn ( @follower_conns ) {

            my $receiver_jid = Ocean::JID->build(
                $follower_conn->username,
                $follower_conn->domain,
                $follower_conn->resource,
            );

            my $builder =
                Ocean::Stanza::DeliveryRequestBuilder::UnavailablePresence->new;
            $builder->from($sender_jid);
            $builder->to($receiver_jid);

            $ctx->deliver($builder->build());
        }
    }
}

1;
