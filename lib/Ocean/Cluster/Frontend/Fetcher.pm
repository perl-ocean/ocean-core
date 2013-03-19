package Ocean::Cluster::Frontend::Fetcher;

use strict;
use warnings;

use Ocean::Error;

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

sub destroy {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Cluster::Frontend::Fetcher::destroy},
    );
}

1;
