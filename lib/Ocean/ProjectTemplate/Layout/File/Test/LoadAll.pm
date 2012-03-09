package Ocean::ProjectTemplate::Layout::File::Test::LoadAll;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { '00_load_all.t' }

1;

__DATA__

use strict;
use warnings;

use Test::LoadAllModules;

BEGIN {
    all_uses_ok(
        search_path => "<: $context.get('handler_class') :>",
        # except => [
        #   
        # ], 
    );  
}

