package Ocean::ProjectTemplate::Layout::File::Starter;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::ExecutableFile';

sub template     { do { local $/; <DATA> } }
sub default_name { 'ocean-start' }

1;

__DATA__
#!/usr/bin/env perl

eval 'exec /usr/bin/perl -w -S $0 ${1+"$@"}' if 0;

use strict;
use warnings;

use FindBin;
use File::Spec;
use lib File::Spec->catdir($FindBin::RealBin, '..', 'lib');
use lib File::Spec->catdir($FindBin::RealBin, '..', 'extlib');
use Getopt::Long;
use Pod::Usage;
use Ocean::Bootstrap::Node;
use AnyEvent;
use Event;

my $help        = 0;
my $daemonize   = 0;
my $config_file = '';

GetOptions(
    'help|?'      => \$help,
    'daemonize|d' => \$daemonize,
    'config=s'    => \$config_file,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(2) unless $config_file;

Ocean::Bootstrap::Node->run( 
    config_file => $config_file ,
    daemonize   => $daemonize,
);

=head1 NAME

oceand - Ocean server starter

=head1 SYNOPSIS

Call this command simply

    ./bin/ocean-start --config config/xmpp.yml

or

    ./bin/ocean-start --config config/xmpp.yml --daemonize

If you run with daemonize, do like as follow to stop the program.
    
    ./bin/ocean-stop --pid var/run/xmpp.pid

=cut

