#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib', 't/lib';

#use lib glob 't/App/*/lib';

use Devel::Leak::Object qw{ GLOBAL_bless };
use Test::TCP;
use LWP::UserAgent;
use Getopt::Long;
use Pod::Usage;
use File::Slurp;
use Ocean::Bootstrap;

my %argv = (
    module => 'ServerSimple',
    port  => empty_port(),
    loop => 1,
);

GetOptions(
    \%argv,
    "module=s",
    "port=i",
    "loop=i",
    "help",
) or $argv{help}++;

pod2usage(2) if $argv{help};

my $module = $argv{module};;
my $port = $argv{port};
my $loop = $argv{loop};

test_tcp(
    client => sub {
        my $port = shift;
        my $ua   = LWP::UserAgent->new;
        for ( 0 .. $loop ) {
            $ua->get("http://127.0.0.1:$port/");
        }
    },
    server => sub {
        my $port = shift;
        my $config = sprintf(<<__END_OF_CONFIG__, $port);
server:
  type: xmpp
  domain: xmpp.example.org
  host: 127.0.0.1
  port: %d
  backlog: 5
  max_connection: 100
  report_interval: 60
  timeout: 10
  max_read_buffer: 1000
event_handler:
  node:       Ocean::Standalone::Handler::Node
  authen:     Ocean::Standalone::Handler::Authen
  connection: Ocean::Standalone::Handler::Connection
  message:    Ocean::Standalone::Handler::Message
  people:     Ocean::Standalone::Handler::People
  room:       Ocean::Standalone::Handler::Room
  p2p:        Ocean::Standalone::Handler::P2P
tls:
  ca_file: /dev/null
log:
  type: print
  formatter: default
  level: crit
sasl:
  mechanisms:
    - PLAIN
    - X-OAUTH
http:
  pending_timeout: 3
handler:
  my_handler_param1: 100
  my_handler_param2: 200
  db_file_path: t/data/database/test01.db
  fixture_file_path: t/data/fixture/test01.pl
  fixture_evaluator: perl
__END_OF_CONFIG__
        my $tmp_conf = q{t/data/config/tmp.yml};
        unlink $tmp_conf if -e $tmp_conf;
        File::Slurp::write_file($tmp_conf, $config);
        Ocean::Bootstrap->run(
            config_file => $tmp_conf,
            daemonize   =>   0,
        );
        unlink $tmp_conf;
    },
);

=head1 NAME

=head1 SYNOPSIS

  tools/memory_leak.pl --loop 5

=cut
