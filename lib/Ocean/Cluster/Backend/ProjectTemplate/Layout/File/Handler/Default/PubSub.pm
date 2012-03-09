package Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Default::PubSub;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'PubSub.pm' }

1;
__DATA__
package <: $context.get('handler_class') :>::PubSub;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::Handler::PubSub';

use Ocean::Error;

=head1 NAME

<: $context.get('handler_class') :>::PubSub - PubSub Event Handler

=head1 METHODS

=head2 on_pubsub_event( $ctx, $node_id, $args )

$args is an aobject of L<Ocean::HandlerArgs::PubSubEvent>.

=cut

sub on_pubsub_event {
    my ($self, $ctx, $node_id, $args) = @_;
    # TODO remove next line and write code by yourself
    $self->log_warn("on_pubsub_event not implemented");
}

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
