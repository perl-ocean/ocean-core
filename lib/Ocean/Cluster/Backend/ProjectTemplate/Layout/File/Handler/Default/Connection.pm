package Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::Connection;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'Connection.pm' }

1;
__DATA__
package <: $context.get('handler_class') :>::Connection;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::Handler::Connection';

use Ocean::Error;
use Ocean::JID;

use Ocean::Stanza::DeliveryRequestBuilder::BoundJID;
use Ocean::Stanza::DeliveryRequestBuilder::Presence;
use Ocean::Stanza::DeliveryRequestBuilder::UnavailablePresence;

=head1 NAME

<: $context.get('handler_class') :>::Connection - Connection Event Handler

=head1 METHODS

=head2 on_bind_request( $ctx, $node_id, $args )

$args is an object of L<Ocean::HandlerArgs::BindJID>.

=cut

sub on_bind_request {
    my ($self, $ctx, $node_id, $args) = @_;
    # TODO remove next line and write code by yourself
    Ocean::Error::NotImplemented->throw(
        message => q{<: $context.get('handler_class') :>::Connection::on_bind_request}, 
    );
}

=head2 on_silent_disconnection( $ctx, $node_id, $args )

$args is an object of L<Ocean::HandlerArgs::SilentDisconnection>

Developer need not to deliver anything in this method.

=cut

sub on_silent_disconnection {
    my ($self, $ctx, $node_id, $args) = @_;
    # TODO remove next line and write code by yourself
    Ocean::Error::NotImplemented->throw(
        message => q{<: $context.get('handler_class') :>::Connection::on_silent_disconnection}, 
    );
}

=head2 on_presence( $ctx, $node_id, $args )

$args is an object of L<Ocean::HandlerArgs::Presence>.

=cut

sub on_presence {
    my ($self, $ctx, $node_id, $args) = @_;
    # TODO remove next line and write code by yourself
    $self->log_warn("on_presence not implemented");
}

=head2 on_initial_presence( $ctx, $node_id, $args )

$args is an object of L<Ocean::HandlerArgs::InitialPresence>.

=cut

sub on_initial_presence {
    my ($self, $ctx, $node_id, $args) = @_;
    # TODO remove next line and write code by yourself
    Ocean::Error::NotImplemented->throw(
        message => q{<: $context.get('handler_class') :>::Connection::on_initial_presence}, 
    );
}

=head2 on_unavailable_presence( $ctx, $node_id, $args )

$args is an object of L<Ocean::HandlerArgs::UnavailablePresence>.

=cut

sub on_unavailable_presence {
    my ($self, $ctx, $node_id, $args) = @_;
    # TODO remove next line and write code by yourself
    Ocean::Error::NotImplemented->throw(
        message => q{<: $context.get('handler_class') :>::Connection::on_unavailable_presence}, 
    );
}

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
