#!/usr/bin/perl
use strict;
use warnings;

use AnyEvent::XMPP::IM::Connection;
use AnyEvent;
use feature 'say';

sub connect_and_disconnect {

    my ($jid, $password, $host, $port) = @_;

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
            $conn->disconnect();
        }, 
        disconnect => sub {
            say 'DISCONNECTED'; 
            $j->send();
        },
    );
    $conn->connect();

    $j->wait();
}


sub main {
    my ($count, $jid, $password, $host, $port) = @ARGV;
    for (; $count > 0; $count--) {
        &connect_and_disconnect($jid, $password, $host, $port);
    }
}

&main();

__END__

=head1 NAME

connect_and_disconnect - performance test

=head1 SYNOPSIS

    ./connect_and_disconnect <COUNT> <JID> <PASSWORD> <HOST> <PORT>

Example

    ./connect_and_disconnect 10 username@xmpp.example.org password 127.0.0.1 5222

=head1 AUTHOR

Lyo Kato, E<lt>lyo.kato@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2012 by Lyo Kato

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut
