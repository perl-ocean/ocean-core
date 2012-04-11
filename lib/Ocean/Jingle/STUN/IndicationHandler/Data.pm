package Ocean::Jingle::STUN::IndicationHandler::Data;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::IndicationHandler';

use Ocean::Jingle::STUN::MethodType qw(SEND DATA);
use Ocean::Jingle::STUN::AttributeType qw(XOR_PEER_ADDRESS);

my %METHOD_MAP = (
    DATA => 'on_channel_data_message',
    SEND => 'on_send_message',
);

sub _method_map {
    my $self = shift;
    return \%METHOD_MAP;
}

sub on_send_message {
    my ($self, $ctx, $sender, $msg) = @_;

    # shoud be indication

    my $peer_address_attr = 
        $msg->get_attribute(Ocean::Jingle::STUN::AttributeType::XOR_PEER_ADDRESS);
    unless ($peer_address_attr) {
        # XXX error?
        return;
    }

    my $data_attr = 
        $msg->get_attribute(Ocean::Jingle::STUN::AttributeType::DATA);
    unless ($data_attr) {
        # XXX error?
        return;
    }

    my $allocation = $ctx->get_allocation_by_address(
        $sender->host, $sender->port);

    $ctx->relay_data_through_allocation(
        $allocation, 
        $peer_address_attr->address, 
        $peer_address_attr->port, 
        $data_attr->data);
}

sub on_channel_data_message {
    my ($self, $ctx, $sender, $msg) = @_;

    my $channel_number_attr = 
        $msg->get_attribute(Ocean::Jingle::STUN::AttributeType::CHANNEL_NUMBER);
    unless ($channel_number_attr) {
        # XXX error?
        return;
    }

    my $data_attr = 
        $msg->get_attribute(Ocean::Jingle::STUN::AttributeType::DATA);
    unless ($data_attr) {
        # XXX error?
        return;
    }

    my $channel = 
        $ctx->get_channel_by_number($channel_number_attr->number);

    $ctx->relay_data_through_channel(
        $channel, 
        $data_attr->data);
}

1;
