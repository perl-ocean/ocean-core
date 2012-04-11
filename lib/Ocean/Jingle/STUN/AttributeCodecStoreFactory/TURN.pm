package Ocean::Jingle::STUN::AttributeCodecStoreFactory::TURN;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodecStoreFactory';
use Ocean::Jingle::STUN::AttributeCodecStore;

use Ocean::Jingle::STUN::AttributeType;
use Ocean::Jingle::STUN::AttributeType qw(
    MAPPED_ADDRESS
    XOR_MAPPED_ADDRESS
    SOFTWARE
    USERNAME
    ERROR_CODE
    REALM
    NONCE
    ALTERNATE_SERVER
    UNKNOWN_ATTRIBUTES
    MESSAGE_INTEGRITY
    FINGERPRINT

    CHANNEL_NUMBER
    LIFETIME
    XOR_PEER_ADDRESS
    DATA
    XOR_RELAYED_ADDRESS
    EVEN_PORT
    REQUESTED_TRANSPORT
    DONT_FRAGMENT
    RESERVATION_TOKEN
);

use Ocean::Jingle::STUN::AttributeCodec::MappedAddress;
use Ocean::Jingle::STUN::AttributeCodec::XORMappedAddress;
use Ocean::Jingle::STUN::AttributeCodec::Software;
use Ocean::Jingle::STUN::AttributeCodec::Username;
use Ocean::Jingle::STUN::AttributeCodec::ErrorCode;
use Ocean::Jingle::STUN::AttributeCodec::Realm;
use Ocean::Jingle::STUN::AttributeCodec::Nonce;
use Ocean::Jingle::STUN::AttributeCodec::AlternateServer;
use Ocean::Jingle::STUN::AttributeCodec::UnknownAttributes;
use Ocean::Jingle::STUN::AttributeCodec::MessageIntegrity;
use Ocean::Jingle::STUN::AttributeCodec::Fingerprint;

use Ocean::Jingle::TURN::AttributeCodec::ChannelNumber;
use Ocean::Jingle::TURN::AttributeCodec::Lifetime;
use Ocean::Jingle::TURN::AttributeCodec::XORPeerAddress;
use Ocean::Jingle::TURN::AttributeCodec::Data;
use Ocean::Jingle::TURN::AttributeCodec::XORPeerAddress;
use Ocean::Jingle::TURN::AttributeCodec::EvenPort;
use Ocean::Jingle::TURN::AttributeCodec::RequestedTransport;
use Ocean::Jingle::TURN::AttributeCodec::DontFragment;
use Ocean::Jingle::TURN::AttributeCodec::ReservationToken;

sub create_store {
    my $class = shift;
    my $store = Ocean::Jingle::STUN::AttributeCodecStore->new;
    $store->register_codec(MAPPED_ADDRESS => 
        Ocean::Jingle::STUN::AttributeCodec::MappedAddress->new);
    $store->register_codec(XOR_MAPPED_ADDRESS => 
        Ocean::Jingle::STUN::AttributeCodec::XORMappedAddress->new);
    $store->register_codec(SOFTWARE => 
        Ocean::Jingle::STUN::AttributeCodec::Software->new);
    $store->register_codec(USERNAME => 
        Ocean::Jingle::STUN::AttributeCodec::Username->new);
    $store->register_codec(ERROR_CODE => 
        Ocean::Jingle::STUN::AttributeCodec::ErrorCode->new);
    $store->register_codec(REALM => 
        Ocean::Jingle::STUN::AttributeCodec::Realm->new);
    $store->register_codec(NONCE => 
        Ocean::Jingle::STUN::AttributeCodec::Nonce->new);
    $store->register_codec(ALTERNATE_SERVER => 
        Ocean::Jingle::STUN::AttributeCodec::AlternateServer->new);
    $store->register_codec(UNKNOWN_ATTRIBUTES => 
        Ocean::Jingle::STUN::AttributeCodec::UnknownAttributes->new);
    $store->register_codec(MESSAGE_INTEGRITY => 
        Ocean::Jingle::STUN::AttributeCodec::MessageIntegrity->new);
    $store->register_codec(FINGERPRINT => 
        Ocean::Jingle::STUN::AttributeCodec::Fingerprint->new);
    $store->register_codec(CHANNEL_NUMBER => 
        Ocean::Jingle::TURN::AttributeCodec::ChannelNumber->new);
    $store->register_codec(LIFETIME => 
        Ocean::Jingle::TURN::AttributeCodec::Lifetime->new);
    $store->register_codec(XOR_PEER_ADDRESS => 
        Ocean::Jingle::TURN::AttributeCodec::XORPeerAddress->new);
    $store->register_codec(DATA => 
        Ocean::Jingle::TURN::AttributeCodec::Data->new);
    $store->register_codec(XOR_RELAYED_ADDRESS => 
        Ocean::Jingle::TURN::AttributeCodec::XORRelayedAddress->new);
    $store->register_codec(EVEN_PORT => 
        Ocean::Jingle::TURN::AttributeCodec::EvenPort->new);
    $store->register_codec(REQUESTED_TRANSPORT => 
        Ocean::Jingle::TURN::AttributeCodec::RequestedTransport->new);
    $store->register_codec(DONT_FRAGMENT => 
        Ocean::Jingle::TURN::AttributeCodec::DontFragment->new);
    $store->register_codec(RESERVATION_TOKEN => 
        Ocean::Jingle::TURN::AttributeCodec::ReservationToken->new);

    return $store;
}

1;

