package Ocean::Stanza::DeliveryRequest::Roster;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

use Ocean::Stanza::DeliveryRequest::RosterItem;
use Ocean::Util::JID qw(to_jid);

__PACKAGE__->mk_accessors(qw(
    to
    request_id
    items
));

sub new {
    my ($class, $args) = @_;
    my $items = delete $args->{items} || [];
    my $self = $class->SUPER::new($args);
    $self->{to} = to_jid($self->{to});
    $self->{items} = [];
    for my $item_args ( @$items ) {
        push( @{ $self->{items} }, 
            Ocean::Stanza::DeliveryRequest::RosterItem->new($item_args) );
    }
    return $self;
}

1;
