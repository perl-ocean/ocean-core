package Ocean::ProjectTemplate::DiskIO;

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

sub gen_dir {
    my ($self, $path) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ProjectTemplate::DiskIO::gen_dir}, 
    );
}

sub dig_dir {
    my ($self, $root, @dirs) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ProjectTemplate::DiskIO::dig_dir}, 
    );
}

sub gen_file {
    my ($self, $path, $content) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ProjectTemplate::DiskIO::gen_file}, 
    );
}

sub gen_executable_file {
    my ($self, $path, $content) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ProjectTemplate::DiskIO::gen_executable_file}, 
    );
}

1;
