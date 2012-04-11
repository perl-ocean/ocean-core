package Ocean::Jingle::STUN::ServerComponent::UDPTransport;

use strict;
use warnings;

use Ocean::Error;

use constant DEFAULT_RECEIVE_SIZE => 1500;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _delegate     => undef, 
        _handle       => undef,
        _host         => $args{host},
        _port         => $args{port},
        _receive_size => $args{receive_size} || DEFAULT_RECEIVE_SIZE,
    }, $class;
    return $self;
}

sub start {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Jingle::STUN::ServerComponent::UDPTransport::start not implemented},    
    );
}

sub send {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Jingle::STUN::ServerComponent::UDPTransport::send not implemented},    
    );

}

sub stop {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Jingle::STUN::ServerComponent::UDPTransport::stop not implemented},    
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
