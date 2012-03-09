package Ocean::Cluster::Frontend::Fetcher;

use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _on_fetch_event => sub {}, 
    }, $class;
    return $self;
}

sub on_fetch_event {
    my ($self, $callback) = @_;
    $self->{_on_fetch_event} = $callback;
}

1;
