package Ocean::Cluster::Backend::ProcessManager::Single;

use strict;
use warnings;

use Log::Minimal;

use parent 'Ocean::Cluster::Backend::ProcessManager';

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _is_running => 0, 
    }, $class;
    return $self;
}

sub can_continue {
    my $self = shift;
    return !$self->{_is_running};
}

sub start {
    my $self = shift;
    $self->{_is_running}++; 
}

sub finish {
    my $self = shift;
}

sub wait_all {
    my $self = shift;
}

1;
