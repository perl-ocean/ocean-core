package Ocean::ProjectTemplate::Shell;

use strict;
use warnings;

use Ocean::ProjectTemplate::Display::Default;
use Ocean::ProjectTemplate::Renderer::Xslate;
use Ocean::ProjectTemplate::Dumper;
use Ocean::ProjectTemplate::Questioner;
use Ocean::ProjectTemplate::Messages::Default;

use Ocean::Util::ShellColor qw(paint_text);
use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _display         => $args{display}    || Ocean::ProjectTemplate::Display::Default->new,
        _renderer        => $args{renderer}   || Ocean::ProjectTemplate::Renderer::Xslate->new,
        _dumper          => $args{dumper}     || Ocean::ProjectTemplate::Dumper->new,
        _messages        => $args{messages}   || Ocean::ProjectTemplate::Messages::Default->new,
        _questioner      => $args{questioner} || Ocean::ProjectTemplate::Questioner->new,
        _layout_designer => $args{layout_designer},
    }, $class;
    return $self;
}

sub show_message {
    my ($self, $message_type, $args, $color) = @_;
    my $message = $self->_render_message( $message_type, $args );
    $message = paint_text($message, $color) if $color;
    $self->{_display}->show_message( $message )
}

sub _render_message {
    my ($self, $message_type, $args) = @_;
    my $template = $self->{_messages}->get_message_of( $message_type );
    return $self->{_renderer}->render( $template, $args );
}

sub run_at {
    my ($self, $root_dir) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ProjectTemplate::Shell::run_at}, 
    );
}

1;
