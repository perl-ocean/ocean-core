package Ocean::ProjectTemplate::Layout::File::Context::Cluster;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { local $/; <DATA> }
sub default_name { 'Context.pm' }

1;
__DATA__
package <: $context.get('context_class') :>;

use strict;
use warnings;

use parent 'Ocean::Cluster::Frontend::Context';

1;
