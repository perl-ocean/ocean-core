package Ocean::Handler::People;

use strict;
use warnings;

use parent 'Ocean::Handler';
use Ocean::Error;
use Ocean::Constants::EventType;

use Log::Minimal;

sub log_debug {
    my $self     = shift;
    my $template = shift;
    debugf('<Handler::People> ' . $template, @_);
}

sub log_info {
    my $self     = shift;
    my $template = shift;
    infof('<Handler::People> ' . $template, @_);
}

sub log_warn {
    my $self     = shift;
    my $template = shift;
    warnf('<Handler::People> ' . $template, @_);
}

sub log_crit {
    my $self     = shift;
    my $template = shift;
    critf('<Handler::People> ' . $template, @_);
}

sub event_method_map { +{
    Ocean::Constants::EventType::ROSTER_REQUEST, 
        'on_roster_request',
    Ocean::Constants::EventType::VCARD_REQUEST, 
        'on_vcard_request',
} }

sub on_roster_request {
    my ($self, $ctx, $args) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Handler::People::on_roster_request}, 
    );
}

sub on_vcard_request {
    my ($self, $ctx, $args) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Handler::People::on_vcard_request}, 
    );
}

1;
