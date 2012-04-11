#!/usr/bin/perl
use strict;
use warnings;

use AnyEvent::XMPP::IM::Connection;
use AnyEvent;
use feature 'say';

sub main {
    my ($host, $port, $jid, $password, $to_jid, $body, $count) = @ARGV;

    my $j = AnyEvent->condvar;

    my $conn = AnyEvent::XMPP::IM::Connection->new(
        jid      => $jid,
        password => $password,
        host     => $host,
        port     => $port,
    );

    $conn->reg_cb(
        session_ready => sub {
            say 'SESSION READY'; 
            for (; $count > 0; $count--) {
                say $count;
                $conn->send_message($to_jid, 'chat', undef, body => $body);
            }

        }, 
    );

    $conn->connect();

    $j->wait();
}

&main();

__END__

=head1 NAME

too_many_connection - performance test

=head1 SYNOPSIS

    perl ./too_many_packets.pl <HOST> <PORT> <JID> <PASSWORD> <TO_JID> <MESSAGE> <COUNT>

Example

    perl ./too_many_packets.pl 127.0.0.1 5222 username@xmpp.example.org password username2@xmpp.example.org "Hello World" 10

=head1 AUTHOR

Lyo Kato, E<lt>lyo.kato@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2012 by Lyo Kato

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
