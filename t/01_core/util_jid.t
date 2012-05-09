use strict;
use warnings;

use Test::More tests => 4;
use Test::Exception;

use Ocean::Util::JID qw(
    to_jid
);

lives_ok {
    my $jid = to_jid('kusanagi@example.org/resource');
    isa_ok $jid, 'Ocean::JID';
};

lives_ok {
    my $jid2 = to_jid('2ndgig@example.org/resource');
    isa_ok $jid2, 'Ocean::JID';
};
