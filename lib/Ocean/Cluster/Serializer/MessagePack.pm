package Ocean::Cluster::Serializer::MessagePack;

use strict;
use warnings;

use parent 'Ocean::Cluster::Serializer';

use Data::MessagePack;

sub initialize {
    my $self = shift;
    $self->{_packer} = Data::MessagePack->new->utf8;
}

sub serialize {
    my ($self, $data) = @_;
    return $self->{_packer}->pack($data);
}

sub deserialize {
    my ($self, $data) = @_;
    return $self->{_packer}->unpack($data);
}

1;
