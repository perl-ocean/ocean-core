package Ocean::Cluster::Backend::Handler::PubSub;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::NodeEventHandler';
use Ocean::Error;
use Ocean::Constants::EventType;

use Log::Minimal;

sub log_debug {
    my $self     = shift;
    my $template = shift;
    debugf('<Handler::PubSub> ' . $template, @_);
}

sub log_info {
    my $self     = shift;
    my $template = shift;
    infof('<Handler::PubSub> ' . $template, @_);
}

sub log_warn {
    my $self     = shift;
    my $template = shift;
    warnf('<Handler::PubSub> ' . $template, @_);
}

sub log_crit {
    my $self     = shift;
    my $template = shift;
    critf('<Handler::PubSub> ' . $template, @_);
}

sub event_method_map { +{
    Ocean::Constants::EventType::PUBLISH_EVENT, 
        'on_pubsub_event',
} }

sub on_pubsub_event {
    my ($self, $ctx, $node_id, $args) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Cluster::Backend::Handler::PubSub::on_pubsub_event}, 
    );
}

1;
