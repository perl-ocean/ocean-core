package Ocean::Handler::Message;

use strict;
use warnings;

use parent 'Ocean::Handler';
use Ocean::Error;
use Ocean::Constants::EventType;

use Log::Minimal;

sub log_debug {
    my $self     = shift;
    my $template = shift;
    debugf('<Handler::Message> ' . $template, @_);
}

sub log_info {
    my $self     = shift;
    my $template = shift;
    infof('<Handler::Message> ' . $template, @_);
}

sub log_warn {
    my $self     = shift;
    my $template = shift;
    warnf('<Handler::Message> ' . $template, @_);
}

sub log_crit {
    my $self     = shift;
    my $template = shift;
    critf('<Handler::Message> ' . $template, @_);
}

sub event_method_map { +{
    Ocean::Constants::EventType::SEND_MESSAGE, 
        'on_message',
} }

sub on_message {
    my ($self, $ctx, $args) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::Handler::Message::on_message}, 
    );
}

1;
