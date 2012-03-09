package Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::People;

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

use parent 'Ocean::Standalone::Cluster::Backend::Handler::People';

1;
