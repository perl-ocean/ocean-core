package Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::Worker;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'Worker.pm' }

1;
__DATA__
package <: $context.get('handler_class') :>::Worker;

use strict;
use warnings;

use parent 'Ocean::Standalone::Cluster::Backend::Handler::Worker';

1;

