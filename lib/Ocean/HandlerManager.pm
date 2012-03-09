package Ocean::HandlerManager;

use strict;
use warnings;

use Ocean::Config;

sub new {
    my $class = shift;
    my $self = bless {
        _handlers => {},
    }, $class;
    return $self;
}

sub config {
    my ($self, $field) = @_;
    return Ocean::Config->instance->get(handler => $field);
}

sub register_handler {
    my ($self, $category, $handler) = @_;
    $self->{_handlers}{$category} = $handler;
    $handler->set_delegate($self);
}

sub _get_handler {
    my ($self, $category) = @_;
    return $self->{_handlers}{$category};
}

sub release_handlers {
    my $self = shift;
    for my $category ( keys %{ $self->{_handlers} } ) {
        my $handler = delete $self->{_handlers}{$category};
        $handler->release();
    }
}

sub release {
    my $self = shift;
    $self->release_handlers();
}

1;
