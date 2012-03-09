package Ocean::Standalone::Fixture::Evaluator::YAML;

use strict;
use warnings;

use parent 'Ocean::Standalone::Fixture::Evaluator';
use Ocean::Util::YAML qw(load_yaml);

sub evaluate {
    my ($self, $filepath) = @_;
    return load_yaml($filepath);
}

1;
