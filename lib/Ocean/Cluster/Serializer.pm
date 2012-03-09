package Ocean::Cluster::Serializer;

use strict;
use warnings;

use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    my $self = bless \%args, $class;
    $self->initialize();
    return $self;
}

sub initialize {
    my $self = shift;
    # template method
}

sub serialize {
    my ($self, $raw_data) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Cluster::Serializer::serialize}, 
    );
}

sub deserialize {
    my ($self, $data) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Cluster::Serializer::deserialize}, 
    );
}

1;
