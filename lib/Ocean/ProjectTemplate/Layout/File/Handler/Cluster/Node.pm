package Ocean::ProjectTemplate::Layout::File::Handler::Cluster::Node;

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

use parent 'Ocean::Cluster::Frontend::Handler::Node';

=head1 NAME

<: $context.get('handler_class') :>::Node - Node Event Handler

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
