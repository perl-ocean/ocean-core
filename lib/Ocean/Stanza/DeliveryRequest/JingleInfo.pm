package Ocean::Stanza::DeliveryRequest::JingleInfo;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

use Ocean::Util::JID qw(to_jid);

__PACKAGE__->mk_accessors(qw(
    id
    to
    from
    token
));

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    $self->{to}   = to_jid($self->{to});
    $self->{from} = to_jid($self->{from});
    return $self;
}

1;
