#!/usr/bin/perl

use utf8;
use strict;
use warnings;
use AnyEvent;
use Getopt::Long;
use Pod::Usage;
use Protocol::WebSocket::Frame;
use Protocol::WebSocket::Request;
use Protocol::WebSocket::Handshake::Client;
use IO::Socket;
use constant {READ => 0, WRITE => 1};

$| = 1;


my $help    = 0;
my $host    = '';
my $port    = '';
my $url     = '';
my $cookies = '';

GetOptions(
    'help|?'    => \$help,
    'host=s'    => \$host,
    'port=s'    => \$port,
    'url=s'     => \$url,
    'cookies=s' => \$cookies,
) or pod2usage(2);

pod2usage(1) if $help;
pod2usage(2) unless $host || $port || $url;

run();

sub run {
  my $cv = AE::cv;
  my $s = IO::Socket::INET->new(PeerAddr => $host, PeerPort => $port, Proto => 'tcp', Blocking => 0);
  if (not $s or not $s->connected) {
    client_exit();
  }

  my $hc = Protocol::WebSocket::Handshake::Client->new(url => $url);
  $hc->req->cookies($cookies) if $cookies;

  # handshare request
  $s->syswrite($hc->to_string);

  my (@messages, $wsr, $wsw, $stdin);

  my $finish = sub { undef $stdin; undef $wsr; undef $wsw; $cv->send; client_exit($s) };

  local @SIG{qw/INT TERM ALRM/} = ($finish) x 3;

  $stdin = AE::io *STDIN, READ, sub {
    my $line = <STDIN>;
    unless ($line) {
      $finish->();
    } else {
      chomp $line;
      push @messages, Encode::decode('utf8', $line)
    }
  };

  $wsw = AE::io $s, WRITE, sub {
    if ($s->connected) {
      while (my $msg = shift @messages) {
        $s->syswrite(Protocol::WebSocket::Frame->new($msg)->to_bytes);
      }
    } else {
      $finish->();
    }
  };

  # parse server response
  my $frame_chunk = '';
  until ($hc->is_done) {
    $s->sysread(my $buf, 1024);
    if ($buf) {
      if ($buf =~ s{(\x00.+)$}{}) {
        $frame_chunk = $1;
      }
      print $buf;
      $hc->parse($buf);
      if ($hc->error) {
        warn $hc->error;
        $finish->();
      }
    }
  }

  my $frame = Protocol::WebSocket::Frame->new();
  $frame->append($frame_chunk) if $frame_chunk;
  $wsr = AE::io $s, READ, sub {
    $s->sysread(my $buf, 100);
    $frame->append($buf);
    while (my $msg = $frame->next) {
      print Encode::encode('utf8', $msg), "\n";
    }
  };

  $cv->recv;

  client_exit($s);
}

sub client_exit {
  my $s = shift;
  close $s if $s;
  exit;
}

=head1 NAME

websocket-client - a simple tool to test websocket

=head1 SYNOPSIS

    ./websocket-client.pl --host [ip] --port [port] --url [url] --cookies [cookies]

=cut
