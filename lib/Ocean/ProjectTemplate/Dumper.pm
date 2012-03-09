package Ocean::ProjectTemplate::Dumper;

use strict;
use warnings;

use Ocean::ProjectTemplate::DiskIO::Default;;
use Ocean::ProjectTemplate::Display::Default;
use Ocean::ProjectTemplate::Renderer::Xslate;
use Ocean::Util::ShellColor qw(paint_text);

use File::Spec ();
use MIME::Base64 qw(decode_base64);

sub new {
    my ($class, %args) = @_;
    my $self = bless { 
        _disk_io  => $args{disk_io}  || Ocean::ProjectTemplate::DiskIO::Default->new, 
        _display  => $args{display}  || Ocean::ProjectTemplate::Display::Default->new, 
        _renderer => $args{renderer} || Ocean::ProjectTemplate::Renderer::Xslate->new,
    }, $class;
    return $self;
}

sub dump_layout {
    my ($self, $layout, $context) = @_;

    my $root = $layout->root_dir();
    my $path = $layout->absolute_project_dir();
    my $dir  = $layout->project_root();

    $self->dump_dir($layout, $context, $root, $path, $dir);
}

sub dump_dir {
    my ($self, $layout, $context, $root, $path, $dir) = @_;

    my $created = $self->{_disk_io}->gen_dir($path);

    if ($created) {
        my $message = paint_text("Created directory : ", Ocean::Util::ShellColor::BLUE);
        $message .= paint_text(File::Spec->abs2rel($path, $root), 
            Ocean::Util::ShellColor::CYAN);
        $self->{_display}->show_message($message);
    }

    for my $filename (sort $dir->get_file_names()) {
        $self->dump_file($layout, $context, $root, 
            File::Spec->catfile($path, $filename), $dir->get_file($filename));
    }

    for my $dirname (sort $dir->get_dir_names()) {
        $self->dump_dir($layout, $context, $root,
            File::Spec->catdir($path, $dirname), $dir->get_dir($dirname));
    }
}

sub dump_file {
    my ($self, $layout, $context, $root, $path, $file) = @_; 

    my $content = $file->is_binary 
        ? decode_base64($file->template)
        : $file->is_simple_text 
            ? $file->template
            : $self->{_renderer}->render($file->template, { 
                    layout  => $layout,
                    context => $context,
                } );

    my $created = 0;
    if ( $file->is_executable() ) { 
        $created = $self->{_disk_io}->gen_executable_file($path, \$content);
    } else { 
        $created = $self->{_disk_io}->gen_file($path, \$content);
    }

    if ($created) {
        my $message = paint_text("Created file      : ", Ocean::Util::ShellColor::BLUE);
        $message .= paint_text(File::Spec->abs2rel($path, $root), Ocean::Util::ShellColor::CYAN);
        $self->{_display}->show_message($message);
    }
}

1;
