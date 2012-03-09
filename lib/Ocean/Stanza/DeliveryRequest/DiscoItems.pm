package Ocean::Stanza::DeliveryRequest::DiscoItems;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';
use Ocean::Stanza::DeliveryRequest::DiscoItem;
use Ocean::Util::JID qw(to_jid);

__PACKAGE__->mk_accessors(qw(
    id
    from
    to
    items
));

sub new {
    my ($class, $args) = @_;
    my $items = delete $args->{items} || [];
    my $self = $class->SUPER::new($args);
    $self->{to} = to_jid($self->{to}) if $self->{to};
    $self->{items} = [];
    for my $item_args ( @$items ) {
        push( @{ $self->{items} }, 
            Ocean::Stanza::DeliveryRequest::DiscoItem->new($item_args) );
    }
    return $self;
}

sub add_item {
    my ($self, $item) = @_;
    push(@{ $self->{items} }, $item);
}

1;

