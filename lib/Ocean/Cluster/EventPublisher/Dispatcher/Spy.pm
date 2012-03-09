package Ocean::Cluster::EventPublisher::Dispatcher::Spy;

use strict;
use warnings;

use parent 'Ocean::Cluster::EventPublisher::Dispatcher';

use Ocean::Constants::Cluster;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _result_queue => [], 
    }, $class;
    return $self;
}

sub dispatch {
    my ($self, $data) = @_;
    push(@{ $self->{_result_queue} }, $data);
}

sub get_result_length {
    my $self = shift;
    return scalar(@{ $self->{_result_queue} });
}

sub get_result_at {
    my ($self, $index) = @_;
    return $self->{_result_queue}[$index];
}

1;

