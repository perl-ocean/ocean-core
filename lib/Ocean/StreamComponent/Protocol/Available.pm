package Ocean::StreamComponent::Protocol::Available;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::Protocol';

use Ocean::Config;
use Ocean::Constants::ProtocolPhase;
use Ocean::Stanza::DeliveryRequest::DiscoInfo;
use Ocean::Stanza::DeliveryRequest::DiscoInfoIdentity;
use Ocean::Stanza::DeliveryRequest::DiscoItems;
use Ocean::Stanza::DeliveryRequest::DiscoItem;
use Ocean::XML::Namespaces qw(MUC VCARD JINGLE_INFO);

sub on_client_received_message {
    my ($self, $message) = @_;
    $self->{_delegate}->on_protocol_handle_message($message);
}

sub on_client_received_presence {
    my ($self, $presence) = @_;
    $self->{_delegate}->on_protocol_handle_presence($presence)
}

sub on_client_received_roster_request {
    my ($self, $req) = @_;
    $self->{_delegate}->on_protocol_handle_roster_request($req)
}

sub on_client_received_vcard_request {
    my ($self, $req) = @_;
    $self->{_delegate}->on_protocol_handle_vcard_request($req)
}

sub on_client_received_ping {
    my ($self, $ping) = @_;
    $self->{_delegate}->on_protocol_handle_ping($ping);
}

sub on_client_received_disco_info_request {
    my ($self, $req) = @_;
    my $domain = Ocean::Config->instance->get(server => q{domain});
    my $info = Ocean::Stanza::DeliveryRequest::DiscoInfo->new({
        id   => $req->id,
        from => $domain,
    });
    $info->add_identity(
        Ocean::Stanza::DeliveryRequest::DiscoInfoIdentity->new({
            category => 'server',
            type     => 'im',
            name     => $domain,
        }));
    $info->add_feature(VCARD);

    if (Ocean::Config->instance->has_section('jingle')) {
        $info->add_feature(JINGLE_INFO);
    }

    $self->{_delegate}->on_protocol_delivered_disco_info($req->id, $info);
}

sub on_client_received_disco_items_request {
    my ($self, $req) = @_;
    my $domain = Ocean::Config->instance->get(server => q{domain});
    my $items = Ocean::Stanza::DeliveryRequest::DiscoItems->new({
        id   => $req->id,
        from => $domain,
    });
    if (Ocean::Config->instance->has_section('muc')) {
        my $muc_domain = Ocean::Config->instance->get(muc => q{domain});
        $items->add_item(
            Ocean::Stanza::DeliveryRequest::DiscoItem->new({
                name => q{Group Chat Service},
                jid  => $muc_domain,
            }));
    }
    $self->{_delegate}->on_protocol_delivered_disco_items($req->id, $items);
}

sub on_client_received_room_service_info_request {
    my ($self, $req) = @_;
    my $domain = Ocean::Config->instance->get(muc => q{domain});
    my $info = Ocean::Stanza::DeliveryRequest::DiscoInfo->new({
        id   => $req->id,
        from => $domain,
    });
    $info->add_identity(
        Ocean::Stanza::DeliveryRequest::DiscoInfoIdentity->new({
            category => 'conference',
            type     => 'text',
            name     => 'Group Chat Service',
        }));
    $info->add_feature(MUC);
    $info->add_feature(VCARD);
    $self->{_delegate}->on_protocol_delivered_room_service_info($req->id, $info);
}

sub on_client_received_room_info_request {
    my ($self, $req) = @_;
    $self->{_delegate}->on_protocol_handle_room_info_request($req);
}

sub on_client_received_room_list_request {
    my ($self, $req) = @_;
    $self->{_delegate}->on_protocol_handle_room_list_request($req);
}

sub on_client_received_room_members_list_request {
    my ($self, $req) = @_;
    $self->{_delegate}->on_protocol_handle_room_members_list_request($req);
}

sub on_client_received_room_message {
    my ($self, $message) = @_;
    $self->{_delegate}->on_protocol_handle_room_message($message);
}

sub on_client_received_room_invitation {
    my ($self, $invitation) = @_;
    $self->{_delegate}->on_protocol_handle_room_invitation($invitation);
}

sub on_client_received_room_invitation_decline {
    my ($self, $decline) = @_;
    $self->{_delegate}->on_protocol_handle_room_invitation_decline($decline);
}

sub on_client_received_room_presence {
    my ($self, $presence) = @_;
    $self->{_delegate}->on_protocol_handle_room_presence($presence);
}

sub on_client_received_leave_room_presence {
    my ($self, $presence) = @_;
    $self->{_delegate}->on_protocol_handle_leave_room_presence($presence);
}

sub on_client_received_jingle_info_request {
    my ($self, $req) = @_;
    $self->{_delegate}->on_protocol_handle_jingle_info_request($req);
}

sub on_client_received_iq_toward_user {
    my ($self, $req) = @_;
    $self->{_delegate}->on_protocol_handle_iq_toward_user($req);
}

sub on_client_received_iq_toward_room_member {
    my ($self, $req) = @_;
    $self->{_delegate}->on_protocol_handle_iq_toward_room_member($req);
}

sub on_server_delivered_message {
    my ($self, $message) = @_;
    $self->{_delegate}->on_protocol_delivered_message($message);
}

sub on_server_delivered_presence {
    my ($self, $presence) = @_;
    $self->{_delegate}->on_protocol_delivered_presence($presence);
}

sub on_server_delivered_unavailable_presence {
    my ($self, $sender_jid) = @_;
    $self->{_delegate}->on_protocol_delivered_unavailable_presence(
        $sender_jid);
}

sub on_server_delivered_pubsub_event {
    my ($self, $event) = @_;
    $self->{_delegate}->on_protocol_delivered_pubsub_event($event);
}

sub on_server_delivered_roster {
    my ($self, $iq_id, $roster) = @_;
    $self->{_delegate}->on_protocol_delivered_roster(
        $iq_id, $roster);
}

sub on_server_delivered_roster_push {
    my ($self, $iq_id, $item) = @_;
    $self->{_delegate}->on_protocol_delivered_roster_push(
        $iq_id, $item);
}

sub on_server_delivered_vcard {
    my ($self, $iq_id, $vcard) = @_;
    $self->{_delegate}->on_protocol_delivered_vcard(
        $iq_id, $vcard);
}

sub on_server_delivered_disco_info {
    my ($self, $iq_id, $info) = @_;
    $self->{_delegate}->on_protocol_delivered_disco_info(
        $iq_id, $info);
}

sub on_server_delivered_disco_items {
    my ($self, $iq_id, $items) = @_;
    $self->{_delegate}->on_protocol_delivered_disco_items(
        $iq_id, $items);
}

sub on_server_delivered_room_invitation {
    my ($self, $invitation) = @_;
    $self->{_delegate}->on_protocol_delivered_room_invitation(
        $invitation);
}

sub on_server_delivered_room_invitation_decline {
    my ($self, $decline) = @_;
    $self->{_delegate}->on_protocol_delivered_room_invitation_decline(
        $decline);
}

sub on_server_delivered_iq_toward_user {
    my ($self, $iq_id, $query) = @_;
    $self->{_delegate}->on_protocol_delivered_iq_toward_user(
        $iq_id, $query);
}

sub on_server_delivered_jingle_info {
    my ($self, $iq_id, $info) = @_;
    $self->{_delegate}->on_protocol_delivered_jingle_info(
        $iq_id, $info);
}

sub on_server_delivered_message_error {
    my ($self, $error) = @_;
    $self->{_delegate}->on_protocol_delivered_message_error($error);
}

sub on_server_delivered_presence_error {
    my ($self, $error) = @_;
    $self->{_delegate}->on_protocol_delivered_presence_error($error);
}

sub on_server_delivered_iq_error {
    my ($self, $error) = @_;
    $self->{_delegate}->on_protocol_delivered_iq_error($error);
}

1;
