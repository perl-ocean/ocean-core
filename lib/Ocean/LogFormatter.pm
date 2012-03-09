package Ocean::LogFormatter;

use strict;
use warnings;

use Ocean::Error;

sub new { bless {}, $_[0] }

sub format {
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::LogFormatter::format}, 
    );
}

1;
