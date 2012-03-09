package Ocean::Stanza::DeliveryRequest::Presence;

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
    room_statuses
    raw_jid
));

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    $self->{from}    = to_jid($self->{from});
    $self->{to}      = to_jid($self->{to});
    $self->{raw_jid} = to_jid($self->{raw_jid}) if $self->{raw_jid};
    #$self->{show} ||= Ocean::Constants::PresenceShow::CHAT;
    return $self;
}

sub priority { 0 }

1;
