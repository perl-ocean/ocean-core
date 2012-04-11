package Ocean::Jingle::STUN::AttributeCodecStoreFactory::ICE;

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
    PRIORITY
    USE_CANDIDATE
    ICE_CONTROLLING
    ICE_CONTROLLED
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

use Ocean::Jingle::ICE::AttributeCodec::Priority;
use Ocean::Jingle::ICE::AttributeCodec::UseCandidate;
use Ocean::Jingle::ICE::AttributeCodec::ICEControlling;
use Ocean::Jingle::ICE::AttributeCodec::ICEControlled;


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

    $store->register_codec(PRIORITY => 
        Ocean::Jingle::ICE::AttributeCodec::Priority->new);
    $store->register_codec(USE_CANDIDATE => 
        Ocean::Jingle::ICE::AttributeCodec::UseCandidate->new);
    $store->register_codec(ICE_CONTROLLING => 
        Ocean::Jingle::ICE::AttributeCodec::ICEControlling->new);
    $store->register_codec(ICE_CONTROLLED => 
        Ocean::Jingle::ICE::AttributeCodec::ICEControlled->new);

    return $store;
}

1;

