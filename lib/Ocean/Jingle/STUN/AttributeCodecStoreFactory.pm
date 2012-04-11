package Ocean::Jingle::STUN::AttributeCodecStoreFactory;

use strict;
use warnings;

use Ocean::Error;

sub create_store {
    my $class = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Jingle::STUN::AttributeCodecStoreFactory::create_store not implemented}, 
    );
}

1;

