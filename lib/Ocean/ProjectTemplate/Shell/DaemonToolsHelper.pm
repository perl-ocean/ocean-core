package Ocean::ProjectTemplate::Shell::DaemonToolsHelper;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Shell';

use Ocean::ProjectTemplate::Question;
use Ocean::ProjectTemplate::Layout;
use Ocean::ProjectTemplate::Context;

use Ocean::Util::ShellColor qw(paint_text);
use Ocean::Util::String qw(trim camelize);
use File::Spec ();

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
    my ($self, $cur_dir) = @_;

    my @dirs = File::Spec->splitdir($cur_dir);
    pop @dirs; # scripts dir
    my $project_name = pop @dirs; # root dirname

    my $root_dir = File::Spec->catdir($cur_dir, '..', '..');

    my $context = Ocean::ProjectTemplate::Context->new;

    $self->show_empty_line(0);
    $self->show_hello_message();

    my $description = <<__END_OF_DESCRIPTION__;
Set account name, this is used for 'setuidgid' before this system run the daemon.
__END_OF_DESCRIPTION__

    my $account_name = $self->{_questioner}->ask( 
        Ocean::ProjectTemplate::Question->new({
            title          => q{[1] Account Name},
            question       => q{What's the account name?},        
            default_answer => q{ocean},
            answer_pattern => qr/^[a-zA-Z]([a-zA-Z0-9\-\_\s]+)?$/,
            description    => $description,
        }) );

    $context->set(account_name => $account_name);

    $self->show_empty_line(1);

    my $layout = Ocean::ProjectTemplate::Layout->new(
        root_dir     => $root_dir, 
        project_name => $project_name,
    );
    
    $self->{_layout_designer}->design($layout, $context);

    $self->{_dumper}->dump_layout($layout, $context);

    $self->show_empty_line(1);
    $self->show_bye_message({ layout => $layout });
}

1;
