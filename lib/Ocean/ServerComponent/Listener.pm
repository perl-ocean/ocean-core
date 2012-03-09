package Ocean::ServerComponent::Listener;

use strict;
use warnings;

use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _host            => $args{host},
        _port            => $args{port}, 
        _backlog         => $args{backlog},
        _max_read_buffer => $args{max_read_buffer},
        _timeout         => $args{timeout},
        _listener        => undef,
        _delegate        => undef,
    }, $class;
    return $self;
}

sub set_delegate {
    my ($self, $delegate) = @_;
    $self->{_delegate} = $delegate;
}

sub release {
    my $self = shift;
    delete $self->{_delegate}
        if $self->{_delegate};
}

sub start {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ServerComponent::Listener::start}, 
    );
}

sub stop {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::ServerComponent::Listener::stop}, 
    );
}

1;
