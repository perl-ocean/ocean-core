package Ocean::ProjectTemplate::DiskIO::Spy;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::DiskIO';

use File::Spec;

sub initialize {
    my $self = shift;
    $self->{_dirs}  = [];
    $self->{_files} = [];
}

sub gen_dir {
    my ($self, $path) = @_;
    push @{ $self->{_dirs} }, $path;
}

sub dig_dir {
    my ($self, $root, @dirs) = @_;
    my $path = $root;
    for my $dir_part ( @dirs ) {
        $path = File::Spec->catdir($path, $dir_part);
        $self->gen_dir($path);
    }
    return $path;
}

sub gen_file {
    my ($self, $path, $content) = @_;
    push @{ $self->{_files} }, +{
        is_executable => 0,
        path          => $path,
        content       => $content,
    };
}

sub gen_executable_file {
    my ($self, $path, $content) = @_;
    push @{ $self->{_files} }, +{
        is_executable => 1,
        path          => $path,
        content       => $content,
    };
}

1;
