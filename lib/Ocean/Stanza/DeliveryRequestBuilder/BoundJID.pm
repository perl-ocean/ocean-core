package Ocean::Stanza::DeliveryRequestBuilder::BoundJID;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::BOUND_JID }

sub stream_id {
    my ($self, $stream_id) = @_;
    $self->{_stream_id} = $stream_id;
    return $self;
}

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

sub photo_url {
    my ($self, $photo_url) = @_;
    $self->{_photo_url} = $photo_url;
    return $self;
}

sub build_args {
    my $self = shift;

    my $args = {};

    Ocean::Error::ParamNotFound->throw(
        message => q{'stream_id' not found}, 
    ) unless exists $self->{_stream_id};

    $args->{stream_id} = $self->{_stream_id};

    Ocean::Error::ParamNotFound->throw(
        message => q{'jid' not found}, 
    ) unless exists $self->{_jid};

    $args->{jid} = $self->{_jid};


    if ($self->{_nickname}) {
        $args->{nickname} = $self->{_nickname};
    }

    if ($self->{_photo_url}) {
        $args->{photo_url} = $self->{_photo_url};
    }

    return $args;
}

1;
