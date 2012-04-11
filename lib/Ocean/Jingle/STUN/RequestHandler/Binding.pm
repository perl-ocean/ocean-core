package Ocean::Jingle::STUN::RequestHandler::Binding;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::RequestHandler';

use Ocean::Jingle::STUN::AttributeType qw(LIFETIME);
use Ocean::Jingle::STUN::ClassType;
use Ocean::Jingle::STUN::MethodType;
use Ocean::Jingle::STUN::MessageBuilder;
use Ocean::Jingle::STUN::Attribute::XORMappedAddress;
use Ocean::Jingle::STUN::AddressFamilyType;

my %METHOD_MAP = (
    'BINDING' => 'on_binding_message',
);

sub _method_map {
    my $self = shift;
    return \%METHOD_MAP;
}

sub on_binding_message {
    my ($self, $ctx, $sender, $msg) = @_;

    return unless ($msg->class  eq Ocean::Jingle::STUN::ClassType::REQUEST
                && $msg->method eq Ocean::Jingle::STUN::MethodType::BINDING);

    my $builder = Ocean::Jingle::STUN::MessageBuilder->new(
        class          => Ocean::Jingle::STUN::ClassType::RESPONSE_SUCCESS, 
        method         => $msg->method, 
        transaction_id => $msg->transaction_id,
    );

    my $attr = Ocean::Jingle::STUN::Attribute::XORMappedAddress->new;
    $attr->set(address => $sender->host);
    $attr->set(port    => $sender->port);
    $attr->set(family  => Ocean::Jingle::STUN::AddressFamilyType::IPV4);
    $builder->add_attribute($attr);

    my $res = $builder->build();

    $ctx->deliver($sender->transport_type, $sender->host, $sender->port, $res);
}

1;
