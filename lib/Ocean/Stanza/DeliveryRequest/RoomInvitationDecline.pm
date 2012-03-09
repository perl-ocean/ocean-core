package Ocean::Stanza::DeliveryRequest::RoomInvitationDecline;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';
use Ocean::Util::JID qw(to_jid);

__PACKAGE__->mk_accessors(qw(
    to
    from
    decliner
    reason
    thread
));

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    $self->{to}       = to_jid($self->{to});
    $self->{from}     = to_jid($self->{from});
    $self->{decliner} = to_jid($self->{decliner});
    return $self;
}

1;
