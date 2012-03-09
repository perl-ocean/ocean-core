package Ocean::Cluster::Frontend::Handler::People;

use strict;
use warnings;

use parent 'Ocean::Handler::People';

use Ocean::Constants::EventType;

sub on_roster_request {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::ROSTER_REQUEST, 
        {
            from           => $args->from->as_string,
            id             => $args->id,
            want_photo_url => $args->want_photo_url,
        }
    );
}

sub on_vcard_request {
    my ($self, $ctx, $args) = @_;
    $ctx->post_job(
        Ocean::Constants::EventType::VCARD_REQUEST, 
        {
            from           => $args->from->as_string,
            id             => $args->id,
            to             => $args->to->as_string,
            want_photo_url => $args->want_photo_url,
        }
    );
}

1;
