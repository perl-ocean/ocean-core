package Ocean::Cluster::Backend::ProcessManager;

use strict;
use warnings;

use Log::Minimal;
use Ocean::Error;

sub new {
    my ($class, %args) = @_;
    my $self = bless {}, $class;
    return $self;
}

sub can_continue {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Cluster::Backend::ProcessManager::can_continue}, 
    );
}

sub start {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Cluster::Backend::ProcessManager::start}, 
    );
}

sub finish {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Cluster::Backend::ProcessManager::finish}, 
    );
}

sub wait_all {
    my $self = shift;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Cluster::Backend::ProcessManager::wait_all}, 
    );
}

1;
