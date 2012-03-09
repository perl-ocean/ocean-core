package Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::Node;

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

use parent 'Ocean::Standalone::Cluster::Backend::Handler::Node';

1;
