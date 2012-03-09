package Ocean::ProjectTemplate::DiskIO::Default;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::DiskIO';

use IO::File;
use File::Spec;

sub gen_dir {
    my ($self, $path) = @_;
    unless (-e $path && -d _) {
        mkdir($path, 0755)
            or die "Couldn't mkdir $path";
        return 1;
    }
    return 0;
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
    unless (-e $path && -f _) {
        my $fh = IO::File->new($path, "w")
            or die "Couldn't write file $path";
        $fh->print($$content);
        $fh->close();
        return 1;
    }
    return 0;
}

sub gen_executable_file {
    my ($self, $path, $content) = @_;
    my $created = $self->gen_file($path, $content);
    if ($created) {
        chmod 0755, $path;
        return 1;
    }
    return 0;
}

1;
