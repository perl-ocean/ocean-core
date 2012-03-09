package Ocean::ProjectTemplate::Layout::File::Handler::Default::Message;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'Message.pm' }

1;
__DATA__
package <: $context.get('handler_class') :>::Message;

use strict;
use warnings;

use parent 'Ocean::Handler::Message';

use Ocean::Error;

use Ocean::Stanza::DeliveryRequestBuilder::ChatMessage;

=head1 NAME

<: $context.get('handler_class') :>::Message - Message Event Handler

=head1 METHODS

=head2 on_message( $ctx, $args )

$args is an aobject of L<Ocean::HandlerArgs::Message>.

=cut

sub on_message {
    my ($self, $ctx, $args) = @_;
    # TODO remove next line and write code by yourself
    $self->log_warn("on_message not implemented");
}

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
