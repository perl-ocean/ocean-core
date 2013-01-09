package Ocean::Standalone::Cluster::Backend::Handler::People;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::Handler::People';

use Ocean::Constants::SubscriptionType;
use Ocean::Stanza::DeliveryRequestBuilder::Roster;
use Ocean::Stanza::DeliveryRequestBuilder::RosterItem;
use Ocean::Stanza::DeliveryRequestBuilder::vCard;

sub on_roster_request {
    my ($self, $ctx, $node_id, $args) = @_;

    my $sender_jid = $args->from;

    my $sender = $ctx->get('db')->find_user_by_username( $sender_jid->node );

    my %relations;
    my @followers = $ctx->get('db')->search_followers_of( $sender );
    for my $follower_id ( @followers ) {
        $relations{ $follower_id } = Ocean::Constants::SubscriptionType::FROM;
    }
    my @followees = $ctx->get('db')->search_followees_of( $sender );
    for my $followee_id ( @followees ) {
        if (exists $relations{ $followee_id }) {
            $relations{ $followee_id } = Ocean::Constants::SubscriptionType::BOTH;
        } else {
            $relations{ $followee_id } = Ocean::Constants::SubscriptionType::TO;
        }
    }

    my $builder = 
        Ocean::Stanza::DeliveryRequestBuilder::Roster->new;
    $builder->to($sender_jid);
    $builder->request_id($args->id);

    for my $user_id ( sort keys %relations ) {
        my $user = $ctx->get('db')->find_user_by_id($user_id);
        next unless $user;
        my $item_jid = Ocean::JID->build(
            $user->username, 
            $sender_jid->domain,
        );

        my $item_builder =
            Ocean::Stanza::DeliveryRequestBuilder::RosterItem->new;
        $item_builder->jid($item_jid);
        $item_builder->nickname($user->nickname);
        $item_builder->subscription($relations{ $user_id });
        $item_builder->photo_url($user->profile_img_url || '')
            if $args->want_photo_url;

        $builder->add_item_builder($item_builder);
    }

    $ctx->deliver($node_id, $builder->build());
}

sub on_vcard_request {
    my ($self, $ctx, $node_id, $args) = @_;

    my $sender_jid = $args->from;

    my $sender = $ctx->get('db')->find_user_by_username( $sender_jid->node );
    my $owner_jid = $args->to;
    # XXX check relation between sender and vcard-owner?

    my $owner = $ctx->get('db')->find_user_by_username( $owner_jid->node );
    unless ($owner) {
        # XXX dispatch IQ error?
        return;
    }

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::vCard->new;
    $builder->to($sender_jid);
    $builder->request_id($args->id);
    $builder->jid($owner_jid);
    $builder->nickname($owner->nickname);
    if ($args->want_photo_url) {
        $builder->photo_url($owner->profile_img_url);
    } else {
        $builder->photo_content_type('image/jpeg');
        $builder->photo($owner->profile_img_b64);
    }

    $ctx->deliver($node_id, $builder->build());
}

1;
