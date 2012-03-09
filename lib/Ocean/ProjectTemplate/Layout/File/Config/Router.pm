package Ocean::ProjectTemplate::Layout::File::Config::Router;

use strict;
use warnings;

use parent 'Ocean::ProjectTemplate::Layout::File';

sub template     { do { local $/; <DATA> } }
sub default_name { 'router.pl' }

1;
__DATA__
router {

    register_broker(mybroker00 => ["192.168.0.2:7000"]);
    # register_broker(mybroker01 => ["192.168.0.2:7001", "192.168.0.3:7001"]);

    default_route({
        broker => 'mybroker00', 
        queue  => 'ocean_default',
    });

    # event_route("message" => {
    #     broker => 'mybroker01', 
    #     queue  => 'ocean01',
    # });

    # event_route(["message", "presence"] => {
    #     broker => 'mybroker02', 
    #     queue  => 'ocean02',
    # });

};

