package Ocean::ProjectTemplate::Layout::File::Scripts::DocGenerator;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::ExecutableFile';

sub template     { do { local $/; <DATA> } }
sub default_name { 'gendoc' }

1;

__DATA__
#!/usr/bin/env perl

eval 'exec /usr/bin/perl -w -S $0 ${1+"$@"}' if 0;

use strict;
use warnings;

use FindBin;
use File::Spec;

use Pod::ProjectDocs;

my $lib    = File::Spec->catdir($FindBin::RealBin, '..', 'lib');
my $extlib = File::Spec->catdir($FindBin::RealBin, '..', 'extlib');
my $out    = File::Spec->catdir($FindBin::RealBin, '..', 'doc');

my $p = Pod::ProjectDocs->new(
    outroot  => $out,
    libroot  => [$lib, $extlib],
    title    => q{<: $layout.project_name :>},
    # desc     => $desc,
    # except   => $except,
    # charset  => $charset,
    # index    => $index,
    # verbose  => $verbose,
    # forcegen => $forcegen,
    # lang     => $lang,
)->gen;

1;
