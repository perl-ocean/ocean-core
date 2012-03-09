package Ocean::ProjectTemplate::LayoutDesigner;

use strict;
use warnings;

use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    my $self = bless { }, $class;
    return $self;
}

sub design {
    my ($self, $layout, $context) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ProjectTemplate::LayoutDesigner::design}, 
    );
}

sub add_module_file {
    my ($self, $layout, $lib_dir, $lib_dir_name, $module_name, $file) = @_;

    my @module_dir = split '::', $module_name;
    my $pm = pop @module_dir;
    my $module_filename = sprintf q{%s.pm}, $pm;

    my $module_dir = ( @module_dir > 0 ) 
        ? $layout->add_dir(join '/', $lib_dir_name, @module_dir)
        : $lib_dir;

    $module_dir->add_file(
        $module_filename, 
        $file );
}

1;
