package Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::Authen;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'Authen.pm' }

1;
__DATA__
package <: $context.get('handler_class') :>::Authen;

use strict;
use warnings;

use parent 'Ocean::Standalone::Cluster::Backend::Handler::Authen';

1;
