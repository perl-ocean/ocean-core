package Ocean::Jingle::STUN::MessageDispatcher;

use strict;
use warnings;

use Ocean::Jingle::STUN::MethodType qw(BINDING);
use Log::Minimal;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _delegate => undef,
        _handlers => {}, 
    }, $class;
    return $self;
}

sub set_delegate {
    my ($self, $delegate) = @_;
    $self->{_delegate} = $delegate;
}

sub add_handler {
    my ($self, $type, $handler) = @_;
    $handler->set_delegate($self);
    $self->{_handlers}{$type} = $handler;
}

sub dispatch_message {
    my ($self, $sender, $message) = @_;
    my $handler = $self->{_handlers}{$message->method};
    unless ($handler) {
        infof('<Dispatcher> unknown method: %s', $message->method);
    }
    $handler->dispatch_message($sender, $message);
}

sub release {
    my $self = shift;
    for my $key (keys %{ $self->{_handlers} }) {
        my $handler = delete $self->{_handlers}{$key};
        $handler->release();
    }
    delete $self->{_delegate}
        if $self->{_delegate};
}

1;
