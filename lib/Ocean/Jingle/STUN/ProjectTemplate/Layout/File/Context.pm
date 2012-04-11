package Ocean::Jingle::STUN::ProjectTemplate::Layout::File::Context;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'Context.pm'            }

1;
__DATA__
package <: $context.get('context_class') :>;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Context';

1;
