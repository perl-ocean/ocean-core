package Ocean::Stanza::DeliveryRequest::PubSubEvent;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';
use Ocean::Stanza::DeliveryRequest::PubSubEventItem;
use Ocean::Util::JID qw(to_jid);

__PACKAGE__->mk_accessors(qw(
    from
    to
    node
    items
));

sub new {
    my ($class, $args) = @_;
    my $items = delete $args->{items} || [];
    my $self = $class->SUPER::new($args);
    $self->{from} = to_jid($self->{from});
    $self->{to}   = to_jid($self->{to});
    $self->{items} = [];
    for my $item_args ( @$items ) {
        push( @{ $self->{items} }, 
            Ocean::Stanza::DeliveryRequest::PubSubEventItem->new($item_args) );
    }
    return $self;
}

1;
