package Ocean::Stanza::DeliveryRequest::UnavailablePresence;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

use Ocean::Util::JID qw(to_jid);

__PACKAGE__->mk_accessors(qw(
    from
    to
));

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    $self->{from} = to_jid($self->{from});
    $self->{to}   = to_jid($self->{to});
    return $self;
}

1;
