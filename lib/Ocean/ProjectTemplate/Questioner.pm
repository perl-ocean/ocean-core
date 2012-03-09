package Ocean::ProjectTemplate::Questioner;

use strict;
use warnings;

use Ocean::ProjectTemplate::Display::Default;
use Ocean::Util::ShellColor qw(paint_text);

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _display => $args{display} || Ocean::ProjectTemplate::Display::Default->new,
    }, $class;
    return $self;
}

sub ask {
    my ($self, $question) = @_;
    my ($answer, $continue);

    $self->{_display}->show_message( 
        paint_text( $question->title . "\n", Ocean::Util::ShellColor::YELLOW))
            if $question->title;

    $self->{_display}->show_message( 
        paint_text($question->description_message . "\n" , Ocean::Util::ShellColor::WHITE))
            if $question->description;

    do {
        $answer = $self->{_display}->readline($question->to_line);
        $answer ||= $question->default_answer;
        $continue = (not defined $answer)
            ? 1 
            : $question->verify_answer($answer) 
                ? 0 
                : 1;
        $self->{_display}->show_message(
            paint_text("Invalid answer, please retry", Ocean::Util::ShellColor::RED))
                if $continue;
    }
    while ($continue);

    my $ack_message = $question->answer_ack_message($answer);
    $self->{_display}->show_message(
        paint_text($ack_message, Ocean::Util::ShellColor::GREEN));

    return $answer;
}

1;
