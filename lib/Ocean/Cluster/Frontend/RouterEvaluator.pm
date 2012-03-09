package Ocean::Cluster::Frontend::RouterEvaluator;

use strict;
use warnings;

use Ocean::Error;

sub evaluate {
    my ($self, $router_file) = @_;
    my $router_pkg  = sprintf <<'__END_OF_ROUTER__', $router_file;
use Ocean::Cluster::Frontend::Router::Declare;
{
    my $file = '%s';
    my $r = require $file;
    return $r;
}
__END_OF_ROUTER__
    my $router = eval($router_pkg);
    if ($@) {
        Ocean::Error::InitializationFailed->throw(
            message => $@, 
        );
    }
    if (!eval { $router->isa('Ocean::Cluster::Frontend::Router') }) {
        Ocean::Error::InitializationFailed->throw(
            message => 'Invalid Router Setting', 
        );
    }
    return $router;
}

1;
