use strict;
use warnings;

use Test::More tests => 12;
use Ocean::Stanza::DeliveryRequest::RosterItem;
use Ocean::Stanza::DeliveryRequestFormatter::XML::RosterItem;

my $item = Ocean::Stanza::DeliveryRequest::RosterItem->new({
    jid          => 'lyo.kato@gmail.com',
    subscription => 'none',
    nickname     => 'Lyo',
    groups       => ['frineds', 'family'],
});
ok(!$item->is_pending_out, '[1] not pending out');
$item->add_pending_out();
ok($item->is_pending_out, '[2] now pending out');
$item->add_pending_out();
ok($item->is_pending_out, '[3] not changed');
ok(!$item->is_pending_in, '[4] not pending in');
$item->add_pending_in();
ok($item->is_pending_out, '[5] out state not changed');
ok($item->is_pending_in, '[6] now pending in');
$item->remove_pending_in();
ok($item->is_pending_out, '[7] out state not changed');
ok(!$item->is_pending_in, '[8] now not pending in');
$item->remove_pending_out();
ok(!$item->is_pending_out, '[9] now not pending out');
ok(!$item->is_pending_in, '[10] in-state not changed');
is(Ocean::Stanza::DeliveryRequestFormatter::XML::RosterItem->format($item), '<item jid="lyo.kato@gmail.com" subscription="none" name="Lyo"><group>frineds</group><group>family</group></item>', 'as xml');
$item->add_pending_out();
is(Ocean::Stanza::DeliveryRequestFormatter::XML::RosterItem->format($item), '<item jid="lyo.kato@gmail.com" subscription="none" name="Lyo" ask="subscribe"><group>frineds</group><group>family</group></item>', 'as xml with pending out');

