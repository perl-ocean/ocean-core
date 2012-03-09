package Ocean::EventDispatcher;

use strict;
use warnings;

use parent 'Ocean::HandlerManager';

use Ocean::Error;
use Ocean::Config;
use Ocean::Registrar::EventCategory;

use Log::Minimal;
use Try::Tiny;

sub _get_event_category {
    my ($self, $event_type) = @_;
    return Ocean::Registrar::EventCategory->get($event_type);
}

sub dispatch {
    my ($self, $event_type, $ctx, $args, $rethrow) = @_;

    my $category = $self->_get_event_category($event_type);

    if ($category) {
        my $handler = $self->_get_handler($category);
        unless ($handler) {
            critf('<Dispatcher> event-handler not found for category: %s', $category);
            return;
        }
        $handler->dispatch($event_type, $ctx, $args, $rethrow);
    } else {
        warnf('<Dispatcher> unknown event_type: %s', $event_type);
    }
}

1;
