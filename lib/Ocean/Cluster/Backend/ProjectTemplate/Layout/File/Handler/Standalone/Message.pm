package Ocean::Cluster::Backend::ProjectTemplate::Layout::File::Handler::Standalone::Message;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'Message.pm' }

1;
__DATA__
package <: $context.get('handler_class') :>::Message;

use strict;
use warnings;

use parent 'Ocean::Standalone::Cluster::Backend::Handler::Message';

1;
