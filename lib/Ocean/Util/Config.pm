package Ocean::Util::Config;

use strict;
use warnings;

use base 'Exporter';

use FindBin;
use File::Spec ();

our %EXPORT_TAGS = (all => [qw(
    project_home
    value_is_true
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

sub value_is_true {
    my $value = shift;
    return (  $value && ( 
              $value eq '1' 
           || $value eq 'yes' 
           || $value eq 'true' 
       ) ) ? 1 : 0;
}

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
