package Ocean::ProjectTemplate::Shell::Default;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Shell';

use Ocean::ProjectTemplate::Context;
use Ocean::ProjectTemplate::Question;
use Ocean::ProjectTemplate::Layout;

use Ocean::Util::ShellColor qw(paint_text);
use Ocean::Util::String qw(trim camelize);

sub show_logo {
    my $self = shift;
    $self->show_message('logo.txt', {}, Ocean::Util::ShellColor::CYAN );
}

sub show_empty_line {
    my ($self, $num) = @_;
    $self->{_display}->show_message("\n" x $num);
}

sub show_hello_message {
    my $self = shift;
    $self->show_message('hello_message.txt', {}, Ocean::Util::ShellColor::WHITE);
}

sub show_bye_message { 
    my ($self, $args) = @_;
    $self->show_message('bye_message.txt', $args, Ocean::Util::ShellColor::WHITE);
}

sub run_at {
    my ($self, $root_dir) = @_;

    my $context = Ocean::ProjectTemplate::Context->new;

    $self->show_empty_line(0);
    $self->show_logo();
    $self->show_hello_message();

    my $description = <<__END_OF_DESCRIPTION__;
At first, please decide your project name.
This program will generate directory according to the name.

For example, if you set 'Foo' for your project name,
'foo' directory will be created on current directory.
This is so called "project top directory".
And some directories and files will be generated under the directory automatically.
__END_OF_DESCRIPTION__

    my $project_name = $self->{_questioner}->ask( 
        Ocean::ProjectTemplate::Question->new({
            title          => q{[1] Project Name},
            question       => q{What's your project name?},        
            answer_pattern => qr/^[a-zA-Z]([a-zA-Z0-9\s]+)?$/,
            description    => $description,
        }) );

    $self->show_empty_line(1);

    my $context_class_candidate = 
        sprintf q{%s::Context}, camelize($project_name);

    $description = <<__END_OF_DESCRIPTION__;
Thus, please set the name of your "context class".
This program generates initial context class's template 
under the library directory for your project with proper manner.
__END_OF_DESCRIPTION__

    my $context_class = $self->{_questioner}->ask( 
        Ocean::ProjectTemplate::Question->new({
            title          => q{[2] Context class name},
            question       => q{What's your context class name?}, 
            default_answer => $context_class_candidate,
            answer_pattern => qr/^([a-zA-Z0-9])|(\:\:)+$/,
            description    => $description,
        }) );

    $context->set(context_class => $context_class);

    my $handler_ns_candidate = 
        sprintf q{%s::Handler}, camelize($project_name);

    $description = <<__END_OF_DESCRIPTION__;
Thus, please set your handlers' namespace.
This program generates initial handler classes' template 
under the library directory for your project with proper manner.
__END_OF_DESCRIPTION__

    my $handler_class = $self->{_questioner}->ask( 
        Ocean::ProjectTemplate::Question->new({
            title          => q{[3] Handler Namespace},
            question       => q{What's your handler namespace?}, 
            default_answer => $handler_ns_candidate,
            answer_pattern => qr/^([a-zA-Z0-9])|(\:\:)+$/,
            description    => $description,
        }) );

    $context->set(handler_class => $handler_class);

    $self->show_empty_line(1);

    my $layout = Ocean::ProjectTemplate::Layout->new(
        project_name => $project_name, 
        root_dir     => $root_dir,
    );
    
    $self->{_layout_designer}->design($layout, $context);

    $self->{_dumper}->dump_layout($layout, $context);

    $self->show_empty_line(1);
    $self->show_bye_message({ layout => $layout });
}

1;

