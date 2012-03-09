package Ocean::Cluster::Serializer::Storable;

use strict;
use warnings;

use parent 'Ocean::Cluster::Serializer';
use Storable ();

sub serialize {
    my ($self, $data) = @_;
    # TODO UTF-8 stuff
    return Storable::nfreeze($data);
}

sub deserialize {
    my ($self, $data) = @_;
    # TODO UTF-8 stuff
    return Storable::thaw($data);
}

1;
