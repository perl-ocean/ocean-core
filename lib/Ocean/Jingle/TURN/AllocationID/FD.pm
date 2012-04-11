package Ocean::Jingle::TURN::AllocationID::FD;

use strict;
use warnings;

use parent 'Ocean::Jingle::TURN::AllocationID';

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _socket_fd => $args{socket_fd},
    }, $class;
    return $self;
}

sub as_string {
    my $self = shift;
    return $self->{_socket_fd};
}

1;
