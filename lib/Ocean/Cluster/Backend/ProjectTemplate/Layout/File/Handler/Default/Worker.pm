package Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::Worker;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'Worker.pm' }

1;
__DATA__
package <: $context.get('handler_class') :>::Worker;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::Handler::Worker';

use Ocean::Error;

=head1 NAME

<: $context.get('handler_class') :>::Worker - Worker Event Handler

=head1 METHODS

=head2 on_worker_init( $ctx, $args )

$args is an aobject of L<Ocean::HandlerArgs::WorkerInitialization>.

=cut

sub on_worker_init {
    my ($self, $ctx, $args) = @_;
    # TODO remove next line and write code by yourself
    $self->log_warn("on_worker_init not implemented");
}

=head2 on_worker_exit( $ctx, $args )

$args is an aobject of L<Ocean::HandlerArgs::WorkerExit>.

=cut

sub on_worker_exit {
    my ($self, $ctx, $args) = @_;
    # TODO remove next line and write code by yourself
    $self->log_warn("on_worker_exit not implemented");
}

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
