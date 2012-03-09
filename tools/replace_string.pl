#!/usr/bin/perl
use strict;
use warnings;

use FindBin;
use File::Spec;
use File::Find::Rule;
use File::Slurp;

use feature 'say';

sub main {

    die "Invalid Argument" unless @ARGV == 2;

    my $from = quotemeta $ARGV[0];
    my $to   = $ARGV[1];
    
    my @module_files = File::Find::Rule->file->name('*.pm')->in(
        File::Spec->catdir($FindBin::RealBin, '..', 'lib'),
        File::Spec->catdir($FindBin::RealBin, '..', 't') );

    my @test_files = File::Find::Rule->file->name('*.t')->in(
        File::Spec->catdir($FindBin::RealBin, '..', 't') );

    my @files = (@module_files, @test_files);
    
    for my $file ( @files ) {
        say "processing file $file";
        my $content = File::Slurp::read_file($file);
        $content =~ s/$from/$to/g;
        File::Slurp::write_file($file, $content);
    }

}

&main();

__END__

