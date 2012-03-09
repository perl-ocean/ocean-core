#!/usr/bin/perl
use strict;
use warnings;

use FindBin;
use File::Spec;
use File::Find::Rule;
use File::Slurp;

use feature 'say';

sub main {

    die "Invalid Argument" unless @ARGV == 1;

    my $target = quotemeta $ARGV[0];
    
    my @files = File::Find::Rule->file->name('*'.$target.'*')->in(
        File::Spec->catdir($FindBin::RealBin, '..', 'lib'),
        File::Spec->catdir($FindBin::RealBin, '..', 't') );

    for my $file ( @files ) {
        say $file;
    }

}

&main();

__END__

