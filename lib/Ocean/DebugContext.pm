package Ocean::DebugContext;

use strict;
use warnings;

use parent 'Ocean::Context';
use Ocean::CommonComponent::Profiler;

sub initialize {
    my $self = shift;
    $self->{_profiler} = Ocean::CommonComponent::Profiler->new;
    $self->log_info('<Context> memory size: %s', 
        $self->{_profiler}->current_process_memory_size_string );
}

sub finalize {
    my $self = shift;
    $self->log_info('<Context> memory size: %s', 
        $self->{_profiler}->current_process_memory_size_string );
}

1;
