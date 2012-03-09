package Ocean::Stanza::DeliveryRequest::DiscoItem;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';
use Ocean::Util::JID qw(to_jid);

__PACKAGE__->mk_accessors(qw(
    jid
    name
));

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    $self->{jid} = to_jid($self->{jid});
    return $self;
}

1;

