use strict;
use warnings;

use Test::More tests => 42; 
use Ocean::JID;

my $bare_jid         = Ocean::JID->new(q{user1@example.org});
my $full_jid         = Ocean::JID->new(q{user2@example.org/res1});
my $host_jid         = Ocean::JID->new(q{example.org});
my $invalid_host_jid = Ocean::JID->new(q{example.org/res1});
my $invalid_jid      = Ocean::JID->new(q{example_org});

ok($bare_jid);
ok($full_jid);
ok($host_jid);
ok($invalid_host_jid);
ok(!$invalid_jid);

# test is_bare
ok($bare_jid->is_bare);
ok(!$full_jid->is_bare);
ok(!$host_jid->is_bare);
ok(!$invalid_host_jid->is_bare);

# test is_host
ok(!$bare_jid->is_host);
ok(!$full_jid->is_host);
ok($host_jid->is_host);
ok($invalid_host_jid->is_host);

# node
is($bare_jid->node, 'user1');
is($full_jid->node, 'user2');
ok(!$host_jid->node);
ok(!$invalid_host_jid->node);

# domain
is($bare_jid->domain, 'example.org');
is($full_jid->domain, 'example.org');
is($host_jid->domain, 'example.org');
is($invalid_host_jid->domain, 'example.org');

# resource
ok(!$bare_jid->resource);
is($full_jid->resource, 'res1');
ok(!$host_jid->resource);
is($invalid_host_jid->resource, 'res1');

# belongs_to
my $base = Ocean::JID->new(q{example.org});
my $sub  = Ocean::JID->new(q{sub.example.org});
ok($sub->belongs_to($base));
ok(!$base->belongs_to($sub));

# eq
ok($base->eq($host_jid));
ok($host_jid->eq($base));
ok(!$sub->eq($host_jid));
ok(!$host_jid->eq($sub));

# as_string
is($bare_jid->as_string, 'user1@example.org');
is($full_jid->as_string, 'user2@example.org/res1');
is($host_jid->as_string, 'example.org');
is($invalid_host_jid->as_string, 'example.org/res1');

# as_bare_string
is($bare_jid->as_bare_string, 'user1@example.org');
is($full_jid->as_bare_string, 'user2@example.org');
is($host_jid->as_bare_string, 'example.org');
is($invalid_host_jid->as_bare_string, 'example.org');

my $build_bare_jid    = Ocean::JID->build(q{user1},q{example.org});
my $build_full_jid    = Ocean::JID->build(q{user2},q{example.org},q{res1});
my $build_invalid_jid = Ocean::JID->build(q{user2}, q{example.org@});

ok($bare_jid);
ok($full_jid);
ok(!$build_invalid_jid);
