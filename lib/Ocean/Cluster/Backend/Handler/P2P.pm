package Ocean::Cluster::Backend::Handler::P2P;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::NodeEventHandler';

use Ocean::Error;
use Ocean::Constants::EventType;

use Log::Minimal;

sub log_debug {
    my $self     = shift;
    my $template = shift;
    debugf('<Handler::P2P> ' . $template, @_);
}

sub log_info {
    my $self     = shift;
    my $template = shift;
    infof('<Handler::P2P> ' . $template, @_);
}

sub log_warn {
    my $self     = shift;
    my $template = shift;
    warnf('<Handler::P2P> ' . $template, @_);
}

sub log_crit {
    my $self     = shift;
    my $template = shift;
    critf('<Handler::P2P> ' . $template, @_);
}

sub event_method_map { +{
    Ocean::Constants::EventType::SEND_IQ_TOWARD_USER,
        'on_toward_user_iq',
} }

sub on_toward_user_iq {
    my ($self, $ctx, $node_id, $args) = @_;
    $self->log_warn("on_toward_user_iq not implemented");
}

1;
