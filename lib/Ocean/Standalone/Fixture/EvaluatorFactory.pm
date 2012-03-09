package Ocean::Standalone::Fixture::EvaluatorFactory;

use strict;
use warnings;

use Module::Load ();

sub new { bless {}, $_[0] }

my %EVALUATOR_MAP = (
    yaml => q{Ocean::Standalone::Fixture::Evaluator::YAML},
    perl => q{Ocean::Standalone::Fixture::Evaluator::Perl},
);

sub create_evaluator {
    my ($self, $type) = @_;

    my $evaluator_class = $EVALUATOR_MAP{ $type } 
        or return;

    Module::Load::load($evaluator_class);

    return $evaluator_class->new;
}

1;
