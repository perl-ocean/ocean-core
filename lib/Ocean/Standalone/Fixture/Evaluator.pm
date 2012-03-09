package Ocean::Standalone::Fixture::Evaluator;

use strict;
use warnings;

use Ocean::Error;

sub new { bless {}, $_[0] }

sub evaluate {
    my ($self, $path) = @_;
    Ocean::Error->throw(
        message => q{Ocean::Standalone::Fixture::Evaluator::evaluate}, 
    );
}

1;
