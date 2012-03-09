package Ocean::Cluster::SerializerFactory;

use strict;
use warnings;

use Module::Load ();

my $SERIALIZER_CLASS_MAP = {
    'storable'    => 'Ocean::Cluster::Serializer::Storable',
    'json'        => 'Ocean::Cluster::Serializer::JSON',
    'messagepack' => 'Ocean::Cluster::Serializer::MessagePack',
};

sub new { bless {}, $_[0] }

sub create {
    my ($class, $type) = @_;

    my $serializer_class = 
        $class->get_serializer_class_by_type($type);

    Module::Load::load($serializer_class);

    my $serializer = $serializer_class->new;
    return $serializer;
}

sub get_serializer_class_by_type {
    my ($class, $type) = @_;
    my $serializer_class = $SERIALIZER_CLASS_MAP->{$type};
    die sprintf("Unknown serializer type '%s'", $type) 
        unless $serializer_class;
    return $serializer_class;
}

1;
