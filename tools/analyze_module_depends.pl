#!/usr/bin/env perl
use strict;
use warnings;
use Module::Depends;
use Devel::FindNamespaces;

main();

sub main {
    my $memory_record = print_depended_modules();
}

sub print_depended_modules {
    my $deps = Module::Depends->new->dist_dir('.')->find_modules;
    foreach my $module ( keys %{ $deps->requires } ) {
        print "#### $module #####################\n";

        my @depended_modules = Devel::FindNamespaces->find($module);
        foreach my $depend (@depended_modules) {
            print "$depend\n" unless $depend =~ /$module/;
        }
        print "--------------------------------------\n";
    }
}

__END__

svn co http://svn.coderepos.org/share/lang/perl/Devel-FindNamespaces/trunk Devel-FindNamespaces

cd Devel-FindNamespaces
perl Makefile.PL
make 
make test
sudo make install  
