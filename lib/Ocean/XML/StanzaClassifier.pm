package Ocean::XML::StanzaClassifier;

use strict;
use warnings;

use Ocean::Error;

sub classify {
    my ($self, $elem) = @_;
    Ocean::AbstractMethod->throw(
        message => q{Ocean::XML::StanzaClassifier::classify}, 
    );
}

1;
