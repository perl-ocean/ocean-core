package Ocean::Jingle::STUN::AttributeCodec::Address;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::AttributeCodec::Normal';
use Ocean::Jingle::STUN::AddressFamilyType qw(IPV4 IPV6);
use Ocean::Error;

use AnyEvent::Socket ();

sub create_attribute {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Jingle::STUN::AttributeCodec::Address::create_attribute not implemented}, 
    );
}

sub decode {
    my ($self, $ctx, $length, $bytes) = @_;

    my $head = substr $bytes, 0, 1, '';

    my $family_vec = vec(substr($bytes, 0, 1, ''), 0, 8);

    my $port = unpack('n', substr($bytes, 0, 2, ''));

    my $attr = $self->create_attribute();
    $attr->set(port => $port);

    if ($family_vec == 0x01) {

        $attr->set(family => IPV4);
        my $addrvec = vec(substr($bytes, 0, 4, ''), 0, 32);
        my $address = AnyEvent::Socket::format_address(pack('N', $addrvec));
        $attr->set(address => $address);

    } elsif ($family_vec == 0x02) {

        $attr->set(family => IPV6);

        my $address1 = vec(substr($bytes, 0, 4, ''), 0, 32);
        my $address2 = vec(substr($bytes, 0, 4, ''), 0, 32);
        my $address3 = vec(substr($bytes, 0, 4, ''), 0, 32);
        my $address4 = vec(substr($bytes, 0, 4, ''), 0, 32);

        my $address = AnyEvent::Socket::format_address(pack('N4', 
            $address1, 
            $address2,
            $address3,
            $address4,
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
        $bytes = pack('xCn', 0x01, $port);
        $bytes .= AnyEvent::Socket::parse_ipv4($address);
    }
    elsif ($family eq IPV6) {
        $bytes = pack('xCn', 0x02, $port);
        $bytes .= AnyEvent::Socket::parse_ipv6($address);
    }
    else {
        die "Invalid address family";
    }

    return $bytes;
}

1;
