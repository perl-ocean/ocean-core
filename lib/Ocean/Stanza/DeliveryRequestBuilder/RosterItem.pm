package Ocean::Stanza::DeliveryRequestBuilder::RosterItem;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::DELIVER_ROSTER_PUSH }

sub jid {
    my ($self, $jid) = @_;
    $self->{_jid} = "$jid";
    return $self;
}

sub nickname {
    my ($self, $nickname) = @_;
    $self->{_nickname} = $nickname;
    return $self;
}

sub subscription {
    my ($self, $subscription) = @_;
    $self->{_subscription} = $subscription;
    return $self;
}

sub photo_url {
    my ($self, $photo_url) = @_;
    $self->{_photo_url} = $photo_url;
    return $self;
}

sub build_args {
    my $self = shift;

    my $args = {};

    Ocean::Error::ParamNotFound->throw(
        message => q{'jid' not found}, 
    ) unless exists $self->{_jid};

    $args->{jid} = $self->{_jid};

    Ocean::Error::ParamNotFound->throw(
        message => q{'nickname' not found}, 
    ) unless exists $self->{_nickname};

    $args->{nickname} = $self->{_nickname};

    Ocean::Error::ParamNotFound->throw(
        message => q{'subscription' not found}, 
    ) unless exists $self->{_subscription};

    $args->{subscription} = $self->{_subscription};

    $args->{photo_url} = $self->{_photo_url}
        if $self->{_photo_url};

    return $args;
}

1;

