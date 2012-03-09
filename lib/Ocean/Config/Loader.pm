package Ocean::Config::Loader;

use strict;
use warnings;

use Ocean::Util::YAML qw(load_yaml);
use Ocean::Util::Config qw(project_home);
use Ocean::Error;
use Ocean::Config::Validator;

use Storable ();
use Data::Visitor::Lite;
use File::Spec ();
use Log::Minimal;

sub load {
    my ($class, $stuff, $schema ) = @_;
    Ocean::Error->throw(
        type    => 'Config',
        message => "file path is not set"
    ) unless $stuff;
    my $config = $class->_make_config($stuff);
    $class->validate_config($config, $schema);
    $config = $class->substitute_config($config);
    return $config;
}

sub substitute_config {
    my ($class, $config) = @_;
    my $visitor = Data::Visitor::Lite->new(
        [-value => 
            sub {
                my $str = shift;
                return unless defined $str; 
                return $class->_config_substitutions($str);
            }
        ], 
    );
    $config = $visitor->visit($config);
    return $config;
}

sub _config_substitutions {
    my ($class, $val) = @_;
    my $subs = {};
    my $home = Ocean::Util::Config::project_home();
    $subs->{path_to} = sub { File::Spec->catfile($home, shift) };
    my $subs_re = join '|', keys %$subs;
    $val =~ s{__($subs_re)(?:\((.+?)\))?__}{ $subs->{ $1 }->($2) }eg;
    $val;
}

sub validate_config {
    my ($class, $config, $schema) = @_;
    Ocean::Config::Validator->validate_config($config, $schema);
}

sub _make_config {
    my ($class, $stuff) = @_;
    my $config;
    if (ref $stuff && ref $stuff eq 'HASH') {
        $config = Storable::dclone($stuff);
    }
    else {
        $config = load_yaml($stuff);
    }
    return $config;
}

1;
