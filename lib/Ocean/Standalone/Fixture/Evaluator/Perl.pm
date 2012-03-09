package Ocean::Standalone::Fixture::Evaluator::Perl;

use strict;
use warnings;

use parent 'Ocean::Standalone::Fixture::Evaluator';

sub evaluate {
    my ($self, $filepath) = @_;
    return eval { require $filepath };
}

1;
