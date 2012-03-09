package Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::P2P;

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

use parent 'Ocean::Standalone::Cluster::Backend::Handler::P2P';

1;
