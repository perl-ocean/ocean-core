package Ocean::ProjectTemplate::Layout::File::Handler::Default::Room;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'Room.pm' }

1;
__DATA__
package <: $context.get('handler_class') :>::Room;

use strict;
use warnings;

use parent 'Ocean::Handler::Room';

use Ocean::Error;

=head1 NAME

<: $context.get('handler_class') :>::Room - Room Event Handler

=head1 METHODS


=head1 COPYRIGHT AND LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.

=cut

1;
