package Ocean::ProjectTemplate::Layout::File::Stopper;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::ExecutableFile';

sub template     { do { local $/; <DATA> } }
sub default_name { 'ocean-stop' }

1;

__DATA__
#!/usr/bin/env perl

eval 'exec /usr/bin/perl -w -S $0 ${1+"$@"}' if 0;

use strict;
use warnings;

use File::Slurp;
use File::Spec;
use FindBin;
use Getopt::Long;
use Pod::Usage;

my $help     = 0;
my $pid_file = 'var/run/xmpp.pid';

GetOptions(
    'help|?' => \$help,
    'pid=s'  => \$pid_file,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(2) unless $pid_file;

if (-e $pid_file && -f _) {
    my $pid = File::Slurp::slurp($pid_file);
    chomp $pid;
    if (kill(0, $pid)) {
        kill(15, $pid);
    }
}

=head1 NAME

oceand - Ocean server stopper

=head1 SYNOPSIS

Call this command to stop a daemonized Ocean server

    ./bin/ocean-stop --pid var/run/xmpp.pid

=cut

