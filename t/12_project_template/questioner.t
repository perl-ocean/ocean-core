use strict;
use warnings;

use Test::More; 

use Ocean::ProjectTemplate::Question;
use Ocean::ProjectTemplate::Questioner;
use Ocean::ProjectTemplate::Display::Mock;

my $display = Ocean::ProjectTemplate::Display::Mock->new;
$display->register_answer(qr/^MyQuestion1/, 'AnswerA');
$display->register_answer(qr/^MyQuestion2/, 'AnswerB');

my $questioner = Ocean::ProjectTemplate::Questioner->new(
    display => $display,
);

my $answer;
$answer = $questioner->ask(Ocean::ProjectTemplate::Question->new({
    question       => 'MyQuestion1',
    example        => 'MyExample',
    default_answer => 'MyDefaultAnswer',
    answer_pattern => qr/^(AnswerA|AnswerB)$/,
    description    => 'MyDescription',
}));

is($display->get_recorded_message(0), qq{\e[37mMyDescription\nIf you don't input anything but return,\n'MyDefaultAnswer' will be set by default\n\n\e[m}, "Recorded message is correct");
is($display->get_recorded_message(1), qq{MyQuestion1 (example: MyExample)> }, "Recorded message is correct");
is($display->get_recorded_message(2), qq{\e[32mOK. 'AnswerA' is set\e[m}, "Recorded message is correct");
is($answer, q{AnswerA}, "Correct Answer");

$answer = $questioner->ask(Ocean::ProjectTemplate::Question->new({
    question       => 'MyQuestion2',
    example        => 'MyExample',
    default_answer => 'MyDefaultAnswer',
    answer_pattern => qr/^(AnswerA|AnswerB)$/,
    description    => 'MyDescription',
}));

is($display->get_recorded_message(3), qq{\e[37mMyDescription\nIf you don't input anything but return,\n'MyDefaultAnswer' will be set by default\n\n\e[m}, "Recorded message is correct");
is($display->get_recorded_message(4), qq{MyQuestion2 (example: MyExample)> }, "Recorded message is correct");
is($display->get_recorded_message(5), qq{\e[32mOK. 'AnswerB' is set\e[m}, "Recorded message is correct");
is($answer, q{AnswerB}, "Correct Answer");

done_testing;
