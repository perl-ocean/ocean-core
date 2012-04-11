package Ocean::Jingle::STUN::RequestHandler::Allocation;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::RequestHandler';

use Ocean::Jingle::STUN::MethodType qw(ALLOCATE REFRESH);
use Ocean::Jingle::STUN::AttributeType qw(LIFETIME);

my %METHOD_MAP = (
    'ALLOCATE' => 'on_allocation_message',
    'REFRESH'  => 'on_refresh_message',
);

sub _method_map {
    my $self = shift;
    return \%METHOD_MAP;
}

sub on_allocation_message {
    my ($self, $ctx, $sender, $msg) = @_;

    my $lifetime_attr = $msg->get_attribute(LIFETIME);
    my $lifetime = $lifetime_attr 
        ? $lifetime_attr->lifetime 
        : 10 * 60 * 60;
}

sub on_refresh_message {
    my ($self, $ctx, $sender, $msg) = @_;

    my $lifetime_attr = $msg->get_attribute(LIFETIME);
    unless ($lifetime_attr) {
        # XXX invalid REFRESH message
        return;
    }

    my $lifetime = $lifetime_attr->lifetime;

    if ($lifetime == 0) {
        # delete allocation
    } else {
        # update allocation
    }
}

1;
