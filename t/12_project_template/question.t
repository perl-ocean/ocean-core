use strict;
use warnings;

use Test::More; 

use Ocean::ProjectTemplate::Question;

my $q;
$q = Ocean::ProjectTemplate::Question->new({
    question       => 'MyQuestion',
    example        => 'MyExample',
    default_answer => 'MyDefaultAnswer',
    answer_pattern => 'MyAnswerPattern',
    description    => 'MyDescription',
});

is($q->description_message, "MyDescription\nIf you don't input anything but return,\n'MyDefaultAnswer' will be set by default\n", "Correct Description");

$q = Ocean::ProjectTemplate::Question->new({
    question       => 'MyQuestion',
    example        => 'MyExample',
    answer_pattern => 'MyAnswerPattern',
    description    => 'MyDescription',
});

is($q->description_message, "MyDescription", 'Correct Description without Default Answer');

$q = Ocean::ProjectTemplate::Question->new({
    question       => 'MyQuestion',
    example        => 'MyExample',
    default_answer => 'MyDefaultAnswer',
    answer_pattern => 'MyAnswerPattern',
});

is($q->description_message, "", 'Description should be empty if "description" fields is not set');

$q = Ocean::ProjectTemplate::Question->new({
    question       => 'MyQuestion',
    example        => 'MyExample',
    default_answer => 'MyDefaultAnswer',
    answer_pattern => qr/^(AnswerA|AnswerB)$/,
    description    => 'MyDescription',
});

ok($q->verify_answer('AnswerA'), "Answer should be verified");
ok($q->verify_answer('AnswerB'), "Answer should be verified");
ok(!$q->verify_answer('AnswerA2'), "Answer shouldn't be verified");
ok(!$q->verify_answer('Unknwon'), "Answer shouldn't be verified");


is($q->answer_ack_message('AnswerA'), "OK. 'AnswerA' is set", 'Correct Answer Ack');

$q = Ocean::ProjectTemplate::Question->new({
    question            => 'MyQuestion',
    example             => 'MyExample',
    default_answer      => 'MyDefaultAnswer',
    answer_pattern      => qr/^(AnswerA|AnswerB)$/,
    description         => 'MyDescription',
    answer_ack_template => q{Yeah! '%s' is set!},
});

is($q->answer_ack_message('AnswerA'), "Yeah! 'AnswerA' is set!", 'Correct Answer Ack');

# to_line
$q = Ocean::ProjectTemplate::Question->new({
    question            => 'MyQuestion',
    example             => 'MyExample',
    default_answer      => 'MyDefaultAnswer',
    answer_pattern      => qr/^(AnswerA|AnswerB)$/,
    description         => 'MyDescription',
    answer_ack_template => q{Yeah! '%s' is set!},
});

is($q->to_line, q{MyQuestion (example: MyExample)> }, "Correct question message");

$q = Ocean::ProjectTemplate::Question->new({
    question            => 'MyQuestion',
    example             => ['MyExample1', 'MyExample2'],
    default_answer      => 'MyDefaultAnswer',
    answer_pattern      => qr/^(AnswerA|AnswerB)$/,
    description         => 'MyDescription',
    answer_ack_template => q{Yeah! '%s' is set!},
});

is($q->to_line, q{MyQuestion (example: MyExample1,MyExample2)> }, "Correct question message with example as array");

$q = Ocean::ProjectTemplate::Question->new({
    question            => 'MyQuestion',
    default_answer      => 'MyDefaultAnswer',
    answer_pattern      => qr/^(AnswerA|AnswerB)$/,
    description         => 'MyDescription',
    answer_ack_template => q{Yeah! '%s' is set!},
});

is($q->to_line, q{MyQuestion> }, "Correct question message without example");

done_testing;
