package Ocean::Util::YAML;

use strict;
use warnings;

use base 'Exporter';

our %EXPORT_TAGS = (all => [qw(
    load_yaml
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

use YAML;
use Encode;
use Ocean::Error;

# This code is borrowed from Angelos::Utils
sub load_yaml {
    my $filename = shift;
    my $IN;
    if (ref $filename eq 'GLOB') {
        $IN = $filename;
    }
    else {
        open $IN, '<:utf8', $filename
            or Ocean::Error->throw(
                type    => "Config",
                message => "couldn't open file - $filename"
            );
    }
    YAML::Load( Encode::decode('utf8', YAML::Dump( YAML::LoadFile($IN) ) ) );
}

1;
