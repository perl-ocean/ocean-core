package Ocean::ProjectTemplate::Layout::File::Handler::Default::People;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'People.pm' }

1;
__DATA__
package <: $context.get('handler_class') :>::People;

use strict;
use warnings;

use parent 'Ocean::Handler::People';

use Ocean::Error;

use Ocean::Constants::SubscriptionType;

use Ocean::Stanza::DeliveryRequestBuilder::Roster;
use Ocean::Stanza::DeliveryRequestBuilder::RosterItem;
use Ocean::Stanza::DeliveryRequestBuilder::vCard;

=head1 NAME

<: $context.get('handler_class') :>::People - People Event Handler

=head1 METHODS

=head2 on_roster_request( $ctx, $args )

$args is an object of L<Ocean::HandlerArgs::RosterRequest>.

=cut

sub on_roster_request {
    my ($self, $ctx, $args) = @_;
    # TODO remove next line and write code by yourself
    Ocean::Error::NotImplemented->throw(
        message => q{<: $context.get('handler_class') :>::People::on_roster_request}, 
    );
}

=head2 on_vcard_request( $ctx, $args )

$args is an object of L<Ocean::HandlerArgs::vCardRequest>.

=cut

sub on_vcard_request {
    my ($self, $ctx, $args) = @_;
    # TODO remove next line and write code by yourself
    Ocean::Error::NotImplemented->throw(
        message => q{<: $context.get('handler_class') :>::People::on_vcard_request}, 
    );
}

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
