package Ocean::CommonComponent::Profiler;

use strict;
use warnings;

use GTop ();

sub new {
    my ($class, %args) = @_;
    my $self = bless {
    }, $class;
    return $self;
}

sub current_process_memory_size_string {
    my $self = shift;
    return GTop::size_string( $self->current_process_memory_size );
}

sub current_process_memory_size {
    my $self = shift;
    GTop->new->proc_mem($$)->size;
}

1;
