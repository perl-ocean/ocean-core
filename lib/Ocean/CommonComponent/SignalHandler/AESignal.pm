package Ocean::CommonComponent::SignalHandler::AESignal;

use strict;
use warnings;

use parent 'Ocean::CommonComponent::SignalHandler';
use AnyEvent;
use Log::Minimal;

my @DEFAULT_QUIT_SIGNALS = qw(QUIT TERM INT);

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _quit_signals => $args{quit_signals} || \@DEFAULT_QUIT_SIGNALS, 
        _delegate     => undef,
        _handlers     => {},
    }, $class;
    return $self;
}

sub setup {
    my $self = shift;
    for my $sig_type ( @{ $self->{_quit_signals} } ) {
        $self->{_handlers}{$sig_type} = 
            AE::signal $sig_type, 
                sub { $self->_do_quit_handler(); };
    }
}

sub _do_quit_handler {
    my $self = shift;
    $self->_reset_quit_handlers();
    $self->{_delegate}->on_signal_quit();
}

sub _reset_quit_handlers {
    my $self = shift;
    for my $sig_type ( @{ $self->{_quit_signals} } ) {
        delete $self->{_handlers}{$sig_type};
        $self->{_handlers}{$sig_type} = 
            AE::signal $sig_type, 
                sub { $self->_ignore_handler($sig_type); };
    }
}

sub _ignore_handler {
    my ($self, $sig_type) = @_;
    warnf("<Server> Caught signal '%s', but server has already started shutdown", 
        $sig_type);
    warnf("<Server> If you wish to force to kill this process, do 'kill -KILL %s'", $$);
}

sub release {
    my $self = shift;
    delete $self->{_delegate}
        if $self->{_delegate};
    delete $self->{_handlers}{$_} 
        for keys %{ $self->{_handlers} };
}

1;
