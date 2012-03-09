package Ocean::Stanza::DeliveryRequest::RosterItem;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

use Ocean::Util::JID qw(to_jid);

use constant  {
    PENDING_IN   => 1,
    PENDING_OUT  => 2,
};

__PACKAGE__->mk_accessors(qw(
    jid
    user_id
    nickname
    subscription
    pending_state
    groups
    photo_url
));

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    $self->{jid} = to_jid($self->{jid});
    $self->{nickname}      ||= '';
    $self->{subscription}  ||= 'none';
    $self->{groups}        ||= [];
    $self->{pending_state} ||= 0;
    $self->{photo_url}     ||= '';
    return $self;
}

sub add_group {
    push(@{ $_[0]->{groups} }, $_[1]);
}

sub ask { $_[0]->is_pending_out ? 'subscribe' : undef }

sub is_pending_out {
    (($_[0]->{pending_state} & PENDING_OUT) == PENDING_OUT)
        ? 1 : 0;
}

sub is_pending_in {
    (($_[0]->{pending_state} & PENDING_IN) == PENDING_IN)
        ? 1 : 0;
}

sub add_pending_in {
    $_[0]->{pending_state} |= PENDING_IN;
}

sub remove_pending_in {
    $_[0]->{pending_state} &= ~(PENDING_IN);
}

sub add_pending_out {
    $_[0]->{pending_state} |= PENDING_OUT;
}

sub remove_pending_out {
    $_[0]->{pending_state} &= ~(PENDING_OUT);
}

1;

