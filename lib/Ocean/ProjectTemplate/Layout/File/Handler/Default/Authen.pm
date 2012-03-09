package Ocean::ProjectTemplate::Layout::File::Handler::Default::Authen;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'Authen.pm' }

1;
__DATA__
package <: $context.get('handler_class') :>::Authen;

use strict;
use warnings;

use parent 'Ocean::Handler::Authen';

use Ocean::Error;

use Ocean::Stanza::DeliveryRequestBuilder::SASLAuthCompletion;
use Ocean::Stanza::DeliveryRequestBuilder::SASLAuthFailure;
use Ocean::Stanza::DeliveryRequestBuilder::SASLPassword;
use Ocean::Stanza::DeliveryRequestBuilder::HTTPAuthCompletion;
use Ocean::Stanza::DeliveryRequestBuilder::HTTPAuthFailure;

=head1 NAME

<: $context.get('handler_class') :>::Authen - Authen Event Handler

=head1 METHODS

=head2 on_too_many_auth_attempt( $ctx, $args )

When a user tried authentication too many time,
this method will be called.
the limit can be set on config file with 'max-attempt' paramter
in 'sasl' block.

$args is an object of L<Ocean::HandlerArgs::TooManyAuthAttempt>.

Developer need not to deliver anything in this method.

=cut

sub on_too_many_auth_attempt {
    my ($self, $ctx, $args) = @_;
    # TODO remove next line and write code by yourself
    $self->log_warn("on_too_many_auth_attempt");
}

=head2 on_http_auth_request( $ctx, $args )

$args is an object of L<Ocean::HandlerArgs::HTTPAuthRequest>.


Developer must deliver 'delivery request' for 'handshake auth completion event' 
or 'handshake auth failure event' in appropriate manner.

use L<Ocean::Stanza::DeliveryRequestBuilder::HTTPAuthCompletion> 
or L<Ocean::Stanza::DeliveryRequestBuilder::HTTPAuthFailure> for that purpose.

    sub on_http_auth_request {
        my ($self, $args) = @_;
    }

=cut

sub on_http_auth_request {
    my ($self, $ctx, $args) = @_;
    # TODO remove next line and write code by yourself
    Ocean::Error::NotImplemented->throw(
        message => q{<: $context.get('handler_class') :>::Authen::on_http_auth_request}, 
    );
}

=head2 on_sasl_auth_request( $ctx, $args )

$args is an object of L<Ocean::HandlerArgs::SASLAuthRequest>.

Developer must deliver 'delivery request' for 'SASL auth completion event' 
or 'SASL auth failure event' in appropriate manner.

use L<Ocean::Stanza::DeliveryRequestBuilder::SASLAuthCompletion> 
or L<Ocean::Stanza::DeliveryRequestBuilder::SASLAuthFailure> for that purpose.

=cut

sub on_sasl_auth_request {
    my ($self, $ctx, $args) = @_;
    # TODO remove next line and write code by yourself
    Ocean::Error::NotImplemented->throw(
        message => q{<: $context.get('handler_class') :>::Authen::on_sasl_auth_request}, 
    );
}

=head2 on_sasl_password_request( $ctx, $args )

$args is an object of L<Ocean::HandlerArgs::SASLPasswordRequest>.

use L<Ocean::Stanza::DeliveryRequestBuilder::SASLPassword> 
or L<Ocean::Stanza::DeliveryRequestBuilder::SASLAuthFailure> for that purpose.

=cut

sub on_sasl_password_request {
    my ($self, $ctx, $args) = @_;
    # TODO remove next line and write code by yourself
    Ocean::Error::NotImplemented->throw(
        message => q{<: $context.get('handler_class') :>::Authen::on_sasl_password_request}, 
    );
}

=head2 on_sasl_success_notification( $ctx, $args )

$args is an object of L<Ocean::HandlerArgs::SASLSuccessNotification>.

use L<Ocean::Stanza::DeliveryRequestBuilder::SASLAuthCompletion> 
or L<Ocean::Stanza::DeliveryRequestBuilder::SASLAuthFailure> for that purpose.

=cut

sub on_sasl_success_notification {
    my ($self, $ctx, $args) = @_;
    # TODO remove next line and write code by yourself
    Ocean::Error::NotImplemented->throw(
        message => q{<: $context.get('handler_class') :>::Authen::on_sasl_success_notification}, 
    );
}

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
