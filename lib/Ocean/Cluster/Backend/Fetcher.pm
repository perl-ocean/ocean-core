package Ocean::Cluster::Backend::Fetcher;

use strict;
use warnings;
use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    return bless \%args, $class;
}

sub on_fetch {
    my ($self, $callback) = @_;
    $self->{_on_fetch} = $callback if $callback;
}

sub start {
    my $self = shift;    
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Cluster::Backend::Fetcher::start}, 
    );
}

1;
