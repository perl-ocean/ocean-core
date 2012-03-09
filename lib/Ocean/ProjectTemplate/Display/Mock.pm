package Ocean::ProjectTemplate::Display::Mock;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Display';

sub initialize {
    my $self = shift;
    $self->{_message_records} = [];
    $self->{_answer_patterns} = [];
}

sub show_message {
    my ($self, $message) = @_;
    $self->_push_message_record($message);
}

sub readline {
    my ($self, $line) = @_;

    $self->_push_message_record($line);

    for my $pattern ( @{ $self->{_answer_patterns} } ) {
        return $pattern->{answer} 
            if $line =~ $pattern->{condition};
    }

    return;
}

sub _push_message_record {
    my ($self, $message) = @_;
    push @{ $self->{_message_records} }, $message;
}

# for test
sub get_recorded_message {
    my ($self, $idx) = @_;
    return $self->{_message_records}[$idx];
}

sub register_answer {
    my ($self, $condition, $answer) = @_;
    push @{ $self->{_answer_patterns} }, 
        +{
            condition => $condition,
            answer    => $answer,
        };
}

1;
