package Ocean::CommonComponent::SignalHandler::Stub;

use strict;
use warnings;

use parent 'Ocean::CommonComponent::SignalHandler';

sub setup {
    my $self = shift;
    # do nothing
}

sub emulate_quit_signal {
    my $self = shift;
    $self->{_delegate}->on_signal_quit();
}

1;
