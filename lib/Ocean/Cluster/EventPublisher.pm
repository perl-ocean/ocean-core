package Ocean::Cluster::EventPublisher;

use strict;
use warnings;

use Ocean::Constants::EventType;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _serializer => $args{serializer},
        _dispatcher => $args{dispatcher},
    }, $class;
    return $self;
}

sub publish_event {
    my ($self, $event) = @_;

    my $data = $self->{_serializer}->serialize({
        type    => Ocean::Constants::EventType::PUBLISH_EVENT,
        node_id => '__ANON__',
        args    => $event->args, 
    });

    $self->{_dispatcher}->dispatch($data);
}

1;
