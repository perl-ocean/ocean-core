package Ocean::Util::Config;

use strict;
use warnings;

use base 'Exporter';

use FindBin;
use File::Spec ();

our %EXPORT_TAGS = (all => [qw(
    project_home
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

sub project_home {
    my $self = shift;
    my $home = find_home_from_env();
    $home ||= find_home_from_realbin();
    return $home;
}

sub find_home_from_env {
    return $ENV{OCEAN_HOME}; 
}

sub find_home_from_realbin {
    return File::Spec->catdir($FindBin::RealBin, '..');
}

1;
