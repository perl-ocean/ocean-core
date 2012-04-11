#!/usr/bin/perl
use strict;
use warnings;

use AnyEvent::XMPP::IM::Connection;
use AnyEvent;
use feature 'say';

sub connect {

    my ($jid, $password, $host, $port) = @_;

    my $conn = AnyEvent::XMPP::IM::Connection->new(
        jid      => $jid,
        password => $password,
        host     => $host,
        port     => $port,
    );

    $conn->reg_cb(
        session_ready => sub {
            say 'SESSION READY'; 
            #$conn->disconnect();
        }, 
    );
    $conn->connect();

    return $conn;
}


sub main {
    my ($host, $port, $jid, $password, $count) = @ARGV;

    my $j = AnyEvent->condvar;

    my @conns;

    for (; $count > 0; $count--) {
        push(@conns, 
            &connect($jid, $password, $host, $port));
    }

    $j->wait();
}

&main();

__END__

=head1 NAME

too_many_connection - performance test

=head1 SYNOPSIS

    perl ./too_many_connections.pl <HOST> <PORT> <JID> <PASSWORD> <COUNT>

Example

    perl ./too_many_connections.pl 127.0.0.1 5222 username@xmpp.example.org password 10

=head1 AUTHOR

Lyo Kato, E<lt>lyo.kato@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2012 by Lyo Kato

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
