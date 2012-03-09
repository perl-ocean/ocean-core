package Ocean::Config;

use strict;
use warnings;

use Ocean::Config::Loader;

sub initialize { 
    my ($class, %args) = @_;    

    # reset
    no strict 'refs';
    my $instance = \${ "$class\::_instance" };
    $$instance = undef;

    my $schema = \${ "$class\::_schema" };
    $$schema = $args{schema};

    my $path = \${ "$class\::_path" };
    $$path = $args{path};
}

sub instance {
    my $class = shift;
    # already got an object
    return $class if ref $class;
    # we store the instance in the _instance variable in the $class package.
    no strict 'refs';
    my $instance = \${ "$class\::_instance" };
    defined $$instance        
        ? $$instance
        : ($$instance = $class->_new_instance(@_));
}

sub _new_instance {
    my $class = shift;
    my $self = bless {}, $class;

    no strict 'refs';
    my $schema = \${ "$class\::_schema" };
    my $path   = \${ "$class\::_path" };

    $self->{_config} = 
        Ocean::Config::Loader->load(
            $$path, $$schema );
    return $self;
}

sub has_section {
    my ($self, $section) = @_;
    return exists $self->{_config}{$section};
}

sub get {
    my ($self, $section, $var) = @_;
    unless ($self->{_config}{$section}) {
        return;
    }
    unless ($var) {
        return $self->{_config}{$section};
    }
    return $self->{_config}{$section}{$var};
}

1;
