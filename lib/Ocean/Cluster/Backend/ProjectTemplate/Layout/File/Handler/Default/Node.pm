package Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::Node;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'Node.pm' }

1;
__DATA__
package <: $context.get('handler_class') :>::Node;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::Handler::Node';

use Ocean::Error;

=head1 NAME

<: $context.get('handler_class') :>::Node - Node Event Handler

=head1 METHODS

=head2 on_node_init( $ctx, $node_id, $args )

This method will be call immediately at once 
after server prepared listener socket.
Developer should do preparation for their service here.

$args is an object of L<Ocean::HandlerArgs::NodeInitialization>.
This has accessors as follows

=over 4

=item host - listener-socket's address
=item port - listener-socket's port

=back

    sub on_node_init {
        my ($self, $ctx, $node_id, $args) = @_;
        $self->log_info("started to listen at %s:%d", $args->host, $args->port);
    }

=cut

sub on_node_init {
    my ($self, $ctx, $node_id, $args) = @_;
    # TODO remove next line and write code by yourself
    $self->log_warn("on_node_init not implemented");
}

=head2 on_node_timer_report( $ctx, $node_id, $args )

This method will be called periodically.
set 'report_interval' field in 'server' section.

$args is an object of L<Ocean::HandlerArgs::NodeTimerReport>.
This has accessors as follows

=over 4

=item total_connection_counter
=item current_connection_counter

=back

=cut

sub on_node_timer_report {
    my ($self, $ctx, $node_id, $args) = @_;
    # TODO remove next line and write code by yourself
    $self->log_warn("on_node_timer_report not implemented");
}

=head2 on_node_exit( $ctx, $node_id, $args )

Server called this method when it exits.

If developer needs to do some finalization for their service,
do it here.

=cut

sub on_node_exit {
    my ($self, $ctx, $node_id, $args) = @_;
    # TODO remove next line and write code by yourself
    $self->log_warn("on_node_exit not implemented");
}

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
