package Ocean::Cluster::Serializer::JSON;

use strict;
use warnings;

use parent 'Ocean::Cluster::Serializer';

use JSON;

sub initialize {
    my $self = shift;
    $self->{_encoder} = JSON->new->utf8(1);
}

sub serialize {
    my ($self, $data) = @_;
    return $self->{_encoder}->encode($data);
}

sub deserialize {
    my ($self, $data) = @_;
    return $self->{_encoder}->decode($data);
}

1;
