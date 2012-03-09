package Ocean::ProjectTemplate::Renderer::Xslate;

use strict; 
use warnings;

use parent 'Ocean::ProjectTemplate::Renderer';

use Text::Xslate;

sub initialize {
    my $self = shift;
    $self->{_xslate} = Text::Xslate->new( type => 'text' );
}

sub render {
    my ( $self, $string, $args ) = @_;
    $args ||= {};
    return $self->{_xslate}->render_string(
        $string, $args );
}

1;
