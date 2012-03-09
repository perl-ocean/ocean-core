package Ocean::Cluster::EventPublisher::Default;

use strict;
use warnings;

use parent 'Ocean::Cluster::EventPublisher';

use Ocean::Constants::EventType;
use Ocean::Cluster::EventPublisher::Dispatcher::Gearman;
use Ocean::Cluster::Serializer::JSON;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _serializer => Ocean::Cluster::Serializer::JSON->new(%args),
        _dispatcher => Ocean::Cluster::EventPublisher::Dispatcher::Gearman->new(%args),
    }, $class;
    return $self;
}

1;
