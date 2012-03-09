package Ocean::ProjectTemplate::Renderer;

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

sub render {
    my ($self, $file, $args) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ProjectTemplate::Renderer::render}, 
    );
}

1;
