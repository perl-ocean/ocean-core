package Ocean::XML::StanzaParser;

use strict;
use warnings;

use Ocean::Error;

sub new { bless {}, $_[0] }

sub parse {
    my ($self, $element) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::XML::StanzaParser::parse}, 
    );
}

1;
