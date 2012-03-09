package Ocean::ProjectTemplate::Layout;

use strict;
use warnings;

use File::Spec ();
use Ocean::ProjectTemplate::Layout::Dir;
use Ocean::Util::String qw(camelize);

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _root_dir      => $args{root_dir},
        _project_name  => $args{project_name},
        _project_root  => Ocean::ProjectTemplate::Layout::Dir->new,
        _machine_root  => Ocean::ProjectTemplate::Layout::Dir->new,
        _paths         => {},
    }, $class;
    return $self;
}

sub root_dir {
    my $self = shift;
    return $self->{_root_dir};
}

sub project_root {
    my $self = shift;
    return $self->{_project_root};
}

sub project_name {
    my $self = shift;
    return $self->{_project_name};
}

sub relative_project_dir {
    my $self = shift;
    return lc camelize($self->{_project_name});
}

sub absolute_project_dir {
    my $self = shift;
    return File::Spec->catdir($self->{_root_dir},
        $self->relative_project_dir);
}

sub register_path {
    my ($self, $type, $path) = @_;
    $self->{_paths}{ $type } = $path;
}

sub relative_path_for {
    my ($self, $type) = @_;
    return $self->{_paths}{ $type } || '';
}

sub absolute_path_for {
    my ($self, $type) = @_;
    return File::Spec->catfile( $self->absolute_project_dir, 
        $self->relative_path_for($type) );
}

sub add_dir {
    my ($self, $path) = @_;

    my $target = ($path =~ s/^\///) 
        ? $self->{_machine_root}
        : $self->{_project_root};

    my @dirs = File::Spec->splitdir( $path );

    for my $dir_name ( @dirs ) {
        if ( $target->has_dir( $dir_name ) ) {
            $target = $target->get_dir( $dir_name );
        } else {
            my $dir = Ocean::ProjectTemplate::Layout::Dir->new;
            $target->add_dir( $dir_name, $dir );
            $target = $dir;
        }
    }

    return $target;
}

sub get_dir {
    my ($self, $path) = @_;

    my $target = ($path =~ s/^\///) 
        ? $self->{_machine_root}
        : $self->{_project_root};

    my @dirs = File::Spec->splitdir( $path );

    for my $dir_name ( @dirs ) {
        die "Directory for path '%s' is not found" 
            unless $target->has_dir( $dir_name );
        $target = $target->get_dir( $dir_name );
    }
    return $target;
}

sub add_file {
    my $self = shift;
    $self->{_project_root}->add_file(@_);
}

1;
