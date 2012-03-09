package Ocean::Cluster::Backend::ProcessManager::Parallel;

use strict;
use warnings;

use Log::Minimal;
use Parallel::Prefork;

use parent 'Ocean::Cluster::Backend::ProcessManager';

sub new {
    my ($class, %args) = @_;
    my $self = bless {}, $class;
    $self->{_manager} = 
        Parallel::Prefork->new({
            max_workers  => $args{max_workers},
            trap_signals => {
                'TERM' => 'TERM', 
                'HUP'  => 'TERM', 
                'INT'  => 'TERM', 
                'USR1' => undef,
            },
        });
    return $self;
}

sub can_continue {
    my $self = shift;
    return ($self->{_manager}->signal_received !~ /^(?:TERM|INT)$/) 
        ? 1 : 0;
}

sub start {
    my $self = shift;
    return $self->{_manager}->start();
}

sub finish {
    my $self = shift;
    $self->{_manager}->finish();
}

sub wait_all {
    my $self = shift;
    $self->{_manager}->wait_all_children();
}

1;
