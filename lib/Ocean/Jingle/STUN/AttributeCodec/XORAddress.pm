package Ocean::Jingle::STUN::AttributeCodec::XORAddress;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::STUN::AddressFamilyType qw(IPV4 IPV6);
use Ocean::Jingle::STUN::Attribute::XORMappedAddress;
use Ocean::Error;

use AnyEvent::Socket ();

sub create_attribute {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Jingle::STUN::AttributeCodec::XORAddress::create_attribute not implemented}, 
    );
}

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;

    my $head = substr $bytes, 0, 1, '';

    my $family_vec = vec(substr($bytes, 0, 1, ''), 0, 8);

    my $port = vec(substr($bytes, 0, 2, ''), 0, 16) ^ 0x2112;

    my $address_length = $length - 4;

    my $attr = $self->create_attribute();
    $attr->set(port => $port);

    if ($family_vec == 0x01) {

        $attr->set(family => IPV4);
        my $x_address = vec(substr($bytes, 0, 4, ''), 0, 32);
        my $address = AnyEvent::Socket::format_address(pack('N', ($x_address ^ 0x2112a442)));
        $attr->set(address => $address);

    } elsif ($family_vec == 0x02) {

        $attr->set(family => IPV6);

        my $mask_key = '2112a442' . $ctx->transaction_id;
        my $mask_key1 = vec(pack('H8', substr($mask_key,  0, 8)), 0, 32);
        my $mask_key2 = vec(pack('H8', substr($mask_key,  8, 8)), 0, 32);
        my $mask_key3 = vec(pack('H8', substr($mask_key, 16, 8)), 0, 32);
        my $mask_key4 = vec(pack('H8', substr($mask_key, 24, 8)), 0, 32);

        my $x_address1 = vec(substr($bytes, 0, 4, ''), 0, 32);
        my $x_address2 = vec(substr($bytes, 0, 4, ''), 0, 32);
        my $x_address3 = vec(substr($bytes, 0, 4, ''), 0, 32);
        my $x_address4 = vec(substr($bytes, 0, 4, ''), 0, 32);

        my $masked_address1 = $x_address1 ^ $mask_key1;
        my $masked_address2 = $x_address2 ^ $mask_key2;
        my $masked_address3 = $x_address3 ^ $mask_key3;
        my $masked_address4 = $x_address4 ^ $mask_key4;

        my $address = AnyEvent::Socket::format_address(pack('N4', 
            $masked_address1, 
            $masked_address2,
            $masked_address3,
            $masked_address4,
        ));

        $attr->set(address => $address);

    } else {

        die "Invalid address family";

    }

    return $attr;
}

sub encode {
    my ($self, $ctx, $attr) = @_;

    my $family  = $attr->family;
    my $address = $attr->address;
    my $port    = $attr->port;

    my $bytes;
    if ($family eq IPV4) {
        $bytes = pack('xCn', 0x01, $port ^ 0x2112); 
        my $addr_bytes = AnyEvent::Socket::parse_ipv4($address);
        $bytes .= pack('N', (vec($addr_bytes, 0, 32) ^ 0x2112a442));
    }
    elsif ($family eq IPV6) {

        $bytes = pack('xCn', 0x02, $port ^ 0x2112); 
        my $addr_bytes = AnyEvent::Socket::parse_ipv6($address);
        my ($address1, $address2, $address3, $address4) = unpack('NNNN', $addr_bytes);

        my $mask_key = '2112a442' . $ctx->transaction_id;
        my $mask_key1 = vec(pack('H8', substr($mask_key,  0, 8)), 0, 32);
        my $mask_key2 = vec(pack('H8', substr($mask_key,  8, 8)), 0, 32);
        my $mask_key3 = vec(pack('H8', substr($mask_key, 16, 8)), 0, 32);
        my $mask_key4 = vec(pack('H8', substr($mask_key, 24, 8)), 0, 32);

        my $x_address1 = $address1 ^ $mask_key1;
        my $x_address2 = $address2 ^ $mask_key2;
        my $x_address3 = $address3 ^ $mask_key3;
        my $x_address4 = $address4 ^ $mask_key4;

        $bytes .= pack('N4', 
            $x_address1, 
            $x_address2, 
            $x_address3, 
            $x_address4
        );

    }
    else {
        die "Invalid address family";
    }

    return $bytes;
}

1;
