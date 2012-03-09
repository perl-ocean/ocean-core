package Ocean::Stanza::DeliveryRequest::RosterPush;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

use Ocean::Stanza::DeliveryRequest::RosterItem;
use Ocean::Util::JID qw(to_jid);

__PACKAGE__->mk_accessors(qw(
    to
    request_id
    item
));

sub new {
    my ($class, $args) = @_;
    my $item_args = delete $args->{item};
    my $self = $class->SUPER::new($args);
    $self->{to} = to_jid($self->{to});
    $self->{item} = Ocean::Stanza::DeliveryRequest::RosterItem->new($item_args);
    return $self;
}

1;
