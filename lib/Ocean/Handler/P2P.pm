package Ocean::Handler::P2P;

use strict;
use warnings;

use parent 'Ocean::Handler';

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
    Ocean::Constants::EventType::JINGLE_INFO_REQUEST,
        'on_jingle_info_request',
} }

sub on_toward_user_iq {
    my ($self, $ctx, $args) = @_;
    $self->log_warn("on_toward_user_iq not implemented");
}

# http://code.google.com/intl/ja/apis/talk/jep_extensions/jingleinfo.html
sub on_jingle_info_request {
    my ($self, $ctx, $args) = @_;
    $self->log_warn("on_jingle_info_request not implemented");
}

1;
