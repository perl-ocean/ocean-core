package Ocean::JSON::StanzaParser;

use strict;
use warnings;

use Ocean::Error;

sub new { bless {}, $_[0] }

sub parse {
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::JSON::StanzaParser::parse}, 
    );
}

1;
