package Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Context::Default;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'Context.pm' }

1;
__DATA__
package <: $context.get('context_class') :>;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::Context';

1;
