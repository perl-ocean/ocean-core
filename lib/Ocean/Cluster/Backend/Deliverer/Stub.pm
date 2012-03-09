package Ocean::Cluster::Backend::Deliverer::Stub;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::Deliverer';

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _stack => [], 
    }, $class;
    return $self;
}

sub push_deliver_request {
    my ($self, $host, $data) = @_;
    push(@{ $self->{_stack} }, {
        host => $host,
        data => $data,
    });
}

sub count {
    my $self = shift;
    return scalar(@{ $self->{_stack} });
}

sub pop_deliver_request {
    my $self = shift;
    return pop(@{ $self->{_stack} });
}

sub shift_deliver_request {
    my $self = shift;
    return shift(@{ $self->{_stack} });
}

sub deliver {
    my ($self, $host_name, $data) = @_;
    $self->push_deliver_request($host_name, $data);
}

1;
