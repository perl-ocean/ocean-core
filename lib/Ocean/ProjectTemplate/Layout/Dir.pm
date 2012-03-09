package Ocean::ProjectTemplate::Layout::Dir;

use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _dirs  => {}, 
        _files => {},
    }, $class;
    return $self;
}

sub name { $_[0]->{_name} }

sub add_dir {
    my ($self, $name, $dir) = @_;
    $self->{_dirs}{ $name } = $dir;
    return $self;
}

sub has_dir {
    my ($self, $name) = @_;
    return exists $self->{_dirs}{ $name };
}

sub get_dir {
    my ($self, $name) = @_;
    return $self->{_dirs}{ $name };
}

sub get_dir_names {
    my $self = shift;
    return keys %{ $self->{_dirs} };
}

sub add_file {
    my $self = shift;
    my ($name, $file) = (@_ >= 2) 
        ? ($_[0], $_[1]) 
        : ($_[0]->default_name, $_[0]);
    $self->{_files}{ $name } = $file;
    return $self;
}

sub has_file {
    my ( $self, $name ) = @_;
    return exists $self->{_files}{ $name };
}

sub get_file {
    my ( $self, $name ) = @_;
    return $self->{_files}{ $name };
}

sub get_file_names {
    my $self = shift;
    return keys %{ $self->{_files} };
}

1;
