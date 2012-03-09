package Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::Connection;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'Connection.pm' }

1;
__DATA__
package <: $context.get('handler_class') :>::Connection;

use strict;
use warnings;

use parent 'Ocean::Standalone::Cluster::Backend::Handler::Connection';

1;
