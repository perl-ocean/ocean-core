package Ocean::Cluster::Frontend::Fetcher::Stub;

use strict;
use warnings;

use parent 'Ocean::Cluster::Frontend::Fetcher';

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _on_fetch_event => sub {}, 
        _serializer     => $args{serializer},
    }, $class;
    return $self;
}

sub emulate_job {
    my ($self, %args) = @_;
    my $job = $self->{_serializer}->serialize(\%args);
    $self->emulate_raw_job($job);
}

sub emulate_raw_job {
    my ($self, $job) = @_;
    $self->{_on_fetch_event}->($job);
}

1;
