package Ocean::Jingle::STUN::RequestHandler::Permission;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::RequestHandler';

use Ocean::Jingle::STUN::MethodType qw(CHANNEL_BIND CREATE_PERMISSION);

my %METHOD_MAP = (
    CHANNEL_BIND      => 'on_channel_bind_message',
    CREATE_PERMISSION => 'on_create_permission_message',
);

sub _method_map {
    my $self = shift;
    return \%METHOD_MAP;
}

sub on_channel_bind_message {
    my ($self, $ctx, $sender, $msg) = @_;
    # required authentication
}

sub on_create_permission_message {
    my ($self, $ctx, $sender, $msg) = @_;
    # required authentication
}

1;
