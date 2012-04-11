package Ocean::Jingle::STUN::ServerComponent::RelayedTransport;

use strict;
use warnings;

use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _delegate     => undef, 
        _handle       => undef,
        _host         => $args{host},
        _port         => $args{port},
        _receive_size => $args{receive_size} || 1500,
    }, $class;
    return $self;
}

sub start {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Jingle::STUN::ServerComponent::RelayedTransport::start not implemented},    
    );
}

sub send {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Jingle::STUN::ServerComponent::RelayedTransport::send not implemented},    
    );

}

sub stop {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Jingle::STUN::ServerComponent::RelayedTransport::stop not implemented},    
    );
}

sub set_delegate {
    my ($self, $delegate) = @_;
    $self->{_delegate} = $delegate;
}

sub release {
    my $self = shift;
    if ($self->{_delegate}) {
        delete $self->{_delegate};
    }
}

1;
