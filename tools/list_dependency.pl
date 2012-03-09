#!/usr/bin/env perl 

use strict;
use warnings;

use IO::File;
use List::MoreUtils qw(any);
use FindBin;
use File::Spec;
use feature 'say';

my $root_dir = File::Spec->catdir($FindBin::RealBin, '..');

my $ret = `grep -r '^use ' $root_dir`;

my %DEPENDENCY = ();

for my $line ( split /\n/, $ret ) {
    $line = substr($line, index($line, ':') + 1);
    $line =~ s/^use\s//;
    $line =~ s/\;\s*$//;
    next if any { $line =~ /^$_/ } 
        qw(strict warnings vars overload parent base constant lib \$module Ocean inc Module::Install);
    next if $line =~ /^[\d\.]+$/;
    
    $line =~ s/^([^\s]+).*/$1/;
    $DEPENDENCY{$line} = 1;
}

for my $name ( sort keys %DEPENDENCY ) {
    say $name;
}
