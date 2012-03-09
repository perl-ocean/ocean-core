package Ocean::Cluster::Backend::Fetcher::Stub;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::Fetcher';

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _serializer       => $args{serializer}, 
        _required_to_stop => 0,
    }, $class;
    return $self;
}

sub initialize {
    my $self = shift;
    # do nothing
}

sub start {
    my $self = shift;
    # do nothing
}

sub is_required_to_stop {
    my $self = shift;
    return $self->{_required_to_stop};
}

sub stop {
    my $self = shift;
    $self->{_required_to_stop} = 1;
}

sub emulate_job {
    my ($self, %args) = @_;
    my $job = $self->{_serializer}->serialize(\%args);
    $self->{_on_fetch}->($job);
}

sub emulate_raw_job {
    my ($self, $job) = @_;
    $self->{_on_fetch}->($job);
}

1;
