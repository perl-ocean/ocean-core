package Ocean::Stanza::DeliveryRequest::PresenceError;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

use Ocean::Constants::PresenceShow;
use Ocean::Util::JID qw(to_jid);

__PACKAGE__->mk_accessors(qw(
    from
    to
    status
    show
    image_hash
    is_for_room 
    error_type
    error_reason
    error_text
));

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    $self->{from} = to_jid($self->{from});
    $self->{to}   = to_jid($self->{to});
    return $self;
}

sub priority { 0 }

1;
