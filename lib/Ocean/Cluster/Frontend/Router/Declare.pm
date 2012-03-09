package Ocean::Cluster::Frontend::Router::Declare;

use strict;
use warnings;

use parent 'Exporter';

use Ocean::Cluster::Frontend::Router;

our @EXPORT = qw(router register_broker event_route default_route);

our $_ROUTER;

sub router (&) {
    local $_ROUTER = Ocean::Cluster::Frontend::Router->new;
    $_[0]->();
    $_ROUTER;
}

BEGIN {
    no strict 'refs';
    for my $meth (qw(register_broker event_route default_route)) {
        *{$meth} = sub {
            local $Carp::CarpLevel = $Carp::CarpLevel + 1;
            $_ROUTER->$meth(@_);
        };
    }
}

1;
