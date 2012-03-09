package Ocean::Handler::Node;

use strict;
use warnings;

use parent 'Ocean::Handler';
use Ocean::Error;
use Ocean::Constants::EventType;

use Log::Minimal;

sub log_debug {
    my $self     = shift;
    my $template = shift;
    debugf('<Handler::Node> ' . $template, @_);
}

sub log_info {
    my $self     = shift;
    my $template = shift;
    infof('<Handler::Node> ' . $template, @_);
}

sub log_warn {
    my $self     = shift;
    my $template = shift;
    warnf('<Handler::Node> ' . $template, @_);
}

sub log_crit {
    my $self     = shift;
    my $template = shift;
    critf('<Handler::Node> ' . $template, @_);
}

sub event_method_map { +{
    Ocean::Constants::EventType::NODE_INIT, 
        'on_node_init',
    Ocean::Constants::EventType::NODE_TIMER_REPORT, 
        'on_node_timer_report',
    Ocean::Constants::EventType::NODE_EXIT, 
        'on_node_exit',
} }

sub on_node_init {
    my ($self, $ctx, $args) = @_;
    $self->log_warn("on_node_init not implemented");
}

sub on_node_timer_report {
    my ($self, $ctx, $args) = @_;
    $self->log_warn("on_node_timer_report not implemented");
}

sub on_node_exit {
    my ($self, $ctx, $args) = @_;
    $self->log_warn("on_node_exit not implemented");
}

1;
