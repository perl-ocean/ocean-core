package Ocean::ProjectTemplate::Display;

use strict;
use warnings;

use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    my $self = bless \%args, $class;
    $self->initialize();
    return $self;
}

sub initialize {
    my $self = shift;
    # template method
}

sub show_message {
    my ($self, $message) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ProjectTemplate::Display::show_message},
    );
}

sub readline {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ProjectTemplate::Display::readline},
    );
}

1;
