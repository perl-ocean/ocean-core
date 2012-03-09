package Ocean::ProjectTemplate::Question;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw(
   title
   question     
   example
   default_answer
   answer_pattern
   answer_ack_template
   description
));

sub description_message {
    my $self = shift;
    return '' unless $self->description;
    my $msg = $self->description;
    $msg .= sprintf "\nIf you don't input anything but return,\n'%s' will be set by default\n", 
        $self->default_answer 
            if $self->default_answer;
    return $msg;
}

sub verify_answer {
    my ($self, $answer) = @_;
    return 1 unless $self->answer_pattern;
    return $answer =~ $self->answer_pattern;
}

sub to_line {
    my $self = shift;
    my $line = $self->question || 'ocean';
    if (defined $self->example) {
        my $example = (ref $self->example && ref $self->example eq 'ARRAY') 
            ? join(',', @{ $self->example }) 
            : $self->example;
        $line .= sprintf q{ (example: %s)}, $example;
    }
    $line .= '> ';
    return $line;
}

sub answer_ack_message {
    my ($self, $answer) = @_;
    my $template = $self->answer_ack_template || q{OK. '%s' is set};
    return sprintf $template, $answer;
}

1;
