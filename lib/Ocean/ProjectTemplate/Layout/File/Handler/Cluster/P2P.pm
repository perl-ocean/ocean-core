package Ocean::ProjectTemplate::Layout::File::Handler::Cluster::P2P;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'P2P.pm' }

1;
__DATA__
package <: $context.get('handler_class') :>::P2P;

use strict;
use warnings;

use parent 'Ocean::Cluster::Frontend::Handler::P2P';

=head1 NAME

<: $context.get('handler_class') :>::P2P - P2P Event Handler

=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
