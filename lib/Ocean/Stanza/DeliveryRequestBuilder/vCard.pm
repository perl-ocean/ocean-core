package Ocean::Stanza::DeliveryRequestBuilder::vCard;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::DELIVER_VCARD }

sub to {
    my ($self, $to_jid) = @_;
    $self->{_to} = "$to_jid";
    return $self;
}

sub request_id {
    my ($self, $request_id) = @_;
    $self->{_request_id} = $request_id;
    return $self;
}

sub jid {
    my ($self, $jid) = @_;
    $self->{_jid} = "$jid";
    return $self;
}

sub nickname {
    my ($self, $nickname) = @_;
    $self->{_nickname} = "$nickname";
    return $self;
}

sub photo_url {
    my ($self, $photo_url) = @_;
    $self->{_photo_url} = $photo_url;
    return $self;
}

sub photo_content_type {
    my ($self, $photo_content_type) = @_;
    $self->{_photo_content_type} = $photo_content_type;
    return $self;
}

sub photo {
    my ($self, $photo) = @_;
    $self->{_photo} = $photo;
    return $self;
}

sub build_args {
    my $self = shift;

    my $args = {};

    Ocean::Error::ParamNotFound->throw(
        message => q{'to' not found}, 
    ) unless exists $self->{_to};

    $args->{to} = $self->{_to};

    Ocean::Error::ParamNotFound->throw(
        message => q{'request_id' not found}, 
    ) unless exists $self->{_request_id};

    $args->{request_id} = $self->{_request_id};

    Ocean::Error::ParamNotFound->throw(
        message => q{'jid' not found}, 
    ) unless exists $self->{_jid};

    $args->{jid} = $self->{_jid};

    Ocean::Error::ParamNotFound->throw(
        message => q{'nickname' not found}, 
    ) unless exists $self->{_nickname};

    $args->{nickname} = $self->{_nickname};

    $args->{photo_url} = $self->{_photo_url} 
        if $self->{_photo_url};
    $args->{photo_content_type} = $self->{_photo_content_type} 
        if $self->{_photo_content_type};
    $args->{photo} = $self->{_photo} 
        if $self->{_photo};

    return $args;
}

1;
