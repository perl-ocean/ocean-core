package Ocean::Jingle::STUN::Handler;

use strict;
use warnings;

use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _delegate => undef, 
    }, $class;
    return $self;
}

sub set_delegate {
    my ($self, $delegate) = @_;
    $self->{_delegate} = $delegate;
}

sub dispatch_message {
    my ($self, $sender, $msg) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Jingle::STUN::Handler::dispatch_message not implemented}, 
    );
}

sub release {
    my $self = shift;
    delete $self->{_delegate}
        if $self->{_delegate};
}

1;
