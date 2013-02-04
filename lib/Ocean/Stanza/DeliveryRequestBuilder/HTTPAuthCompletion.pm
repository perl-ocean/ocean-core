package Ocean::Stanza::DeliveryRequestBuilder::HTTPAuthCompletion;

use strict;
use warnings;

use parent 'Ocean::Stanza::DeliveryRequestBuilder';
use Ocean::Constants::EventType;
use Ocean::Error;

sub type  { Ocean::Constants::EventType::HTTP_AUTH_COMPLETION }

sub stream_id {
    my ($self, $stream_id) = @_;
    $self->{_stream_id} = $stream_id;
    return $self;
}

sub user_id {
    my ($self, $user_id) = @_;
    $self->{_user_id} = $user_id;
    return $self;
}

sub username {
    my ($self, $username) = @_;
    $self->{_username} = $username;
    return $self;
}

sub session_id {
    my ($self, $session_id) = @_;
    $self->{_session_id} = $session_id;
    return $self;
}

sub add_cookie {
    my ($self, $name, $value) = @_;
    $self->{_cookies} = {} unless exists $self->{_cookies};
    $self->{_cookies}{$name} = $value;
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
        message => q{'user_id' not found}, 
    ) unless exists $self->{_user_id};

    $args->{user_id} = $self->{_user_id};

    Ocean::Error::ParamNotFound->throw(
        message => q{'username' not found}, 
    ) unless exists $self->{_username};

    $args->{username} = $self->{_username};

    Ocean::Error::ParamNotFound->throw(
        message => q{'session_id' not found}, 
    ) unless exists $self->{_session_id};

    $args->{session_id} = $self->{_session_id};
    $args->{cookies} = $self->{_cookies} || {};

    return $args;
}

1;
