package Ocean::Jingle::STUN::ProjectTemplate::Layout::File::Stopper;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::ExecutableFile';

sub template     { do { local $/; <DATA> } }
sub default_name { 'ocean-stun-stop' }

1;

__DATA__
#!/usr/bin/env perl

eval 'exec /usr/bin/perl -w -S $0 ${1+"$@"}' if 0;

use strict;
use warnings;

use File::Slurp;
use File::Spec;
use FindBin;

my $pid_file = File::Spec->catfile($FindBin::RealBin, '..', 'var', 'run', 'ocean_stun.pid');
if (-e $pid_file && -f _) {
    my $pid = File::Slurp::slurp($pid_file);
    chomp $pid;
    if (kill(0, $pid)) {
        kill(15, $pid);
    }
}

