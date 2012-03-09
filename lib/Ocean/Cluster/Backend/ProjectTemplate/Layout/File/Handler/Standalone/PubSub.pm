package Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::PubSub;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'PubSub.pm' }

1;
__DATA__
package <: $context.get('handler_class') :>::PubSub;

use strict;
use warnings;

use parent 'Ocean::Standalone::Cluster::Backend::Handler::PubSub';

1;
