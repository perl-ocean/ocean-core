#!/usr/bin/env perl 

use strict;
use warnings;

use IO::File;
use FindBin;
use File::Spec;
use feature 'say';

my $lib_dir = File::Spec->catdir($FindBin::RealBin, '..', 'lib');
say $lib_dir;
my $ret = `find $lib_dir -name "*.pm"`;

my $count   = 0;
my @modules = ();

for my $line ( split /\n/, $ret ) {
    $count++;
    if ($line =~ /^.*\/lib\/(.+)\.pm$/) {
        my $module = $1;
        $module =~ s/\//::/g;
        push(@modules, $module);
    } else {
        say "unmached";
    }
}

say $_ for @modules;


#my $file = sprintf q| 
#use strict;
#use Test::More tests => %d;
#
#BEGIN {
#|, $count;
#
#for my $module ( @modules ) {
#    $file .= sprintf(q{    use_ok('%s');}, $module);
#    $file .= "\n";
#}
#
#$file .= q|
#};
#|;
#
#my $fh = IO::File->new("t/00_compile.t", "w")
#    or die "failed to open t/00_compile.t";
#$fh->print($file);
#$fh->close();
#
#print "updated t/00_compile.t";
#print "\n";
