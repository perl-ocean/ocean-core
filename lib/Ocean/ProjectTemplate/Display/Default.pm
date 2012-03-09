package Ocean::ProjectTemplate::Display::Default;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Display';

use Term::ReadLine;

use constant PROMPT => 'ocean: ';

sub initialize {
    my $self = shift;
    $self->{_term} = Term::ReadLine->new( PROMPT );
}

sub show_message {
    my ($self, $message) = @_;
    print $message;
    print "\n";
}

sub readline {
    my ($self, $line) = @_;
    return $self->{_term}->readline($line);
}

1;
