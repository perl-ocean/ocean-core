package Ocean::Jingle::TURN::EventHandler;

use strict;
use warnings;

sub on_allocation_request {
    my ($self, $msg, $from) = @_;
}

sub on_create_permission_request {
    my ($self, $msg, $from) = @_;
}

sub on_channel_bind_request {
    my ($self, $msg, $from) = @_;
}

sub on_refresh_request {
    my ($self, $msg, $from) = @_;
}

1;
