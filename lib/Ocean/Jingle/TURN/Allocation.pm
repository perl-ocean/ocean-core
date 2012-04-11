package Ocean::Jingle::TURN::Allocation;

use strict;
use warnings;

use Ocean::Jingle::TURN::Permission;
use AnyEvent;

use constant DEFAULT_LIFETIME => 3600 * 10;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _id                        => $args{id},
        _relayed_transport_address => $args{relayed_transport_address}, 
        _client                    => $args{client},
        _permissions               => {},
        _channels                  => {},
        _lifetime                  => $args{lifetime} || DEFAULT_LIFETIME,
        _timer                     => undef,
        _delegate                  => undef,
    }, $class;
    return $self;
}

sub client { $_[0]->{_client} }
sub relayed_transport_address { $_[0]->{_relayed_transport_address} }

sub set_delegate {
    my ($self, $allocation) = @_;
    $self->{_delegate} = $allocation;
}

sub on_permission_timeout {
    my ($self, $ip_address) = @_;
    my $permission = delete $self->{_permissions}{$ip_address};
    $permission->release();
}

sub verify_incoming_packets_ip_address {
    my ($self, $ip_address) = @_;
    return exists $self->{_permissions};
}

# called when authenticated CreatePermission/ChannelBind request comes
sub on_client_permission_request {
    my ($self, $peer_ip_address) = @_;
    if (exists $self->{_permissions}{$peer_ip_address}) {
        $self->{_permissions}{$peer_ip_address}->refresh();
    } else {
        $self->{_permissions}{$peer_ip_address} =
            $self->create_permission($peer_ip_address);
    }
}

sub create_permission {
    my ($self, $peer_ip_address) = @_;
    my $permission = Ocean::Jingle::TURN::Permission->new(
        ip_address => $peer_ip_address, 
    );
    $permission->set_delegate($self);
    $permission->start_timer();
    return $permission;
}

sub start_timer {
    my ($self, $lifetime) = @_;
    $lifetime ||= $self->{_lifetime};
    $self->{_timer} = AE::timer $lifetime, 0, sub {
        $self->on_timeout();
    };
}

sub stop_timer {
    my $self = shift;
    delete $self->{_timer};
}

sub on_timeout {
    my $self = shift;
    $self->{_delegate}->on_allocation_timeout(
        $self->{_id});
}

sub release {
    my $self = shift;
    for my $peer_ip ( keys %{ $self->{_permissions} } ) {
        my $permission = delete $self->{_permissions}{$peer_ip};
        $permission->release();
    }
    delete $self->{_delegate}
        if $self->{_delegate};
    delete $self->{_timer}
        if $self->{_timer};
}

sub DESTROY {
    my $self = shift;
    $self->release();
}

1;
