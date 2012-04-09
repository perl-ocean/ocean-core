package Ocean::Config::Schema::Log;

use strict;
use warnings;

sub config {
    my $schema = {
        type     => 'map',
        required => 1,
        mapping  => {
            type         => { type => 'str', required => 1 }, 
            level        => { type => 'str', required => 1 }, 
            show_packets => { type => 'bool' },
            date_pattern => { type => 'str' }, 
            filepath     => { type => 'str' }, 
            tz           => { type => 'str' }, 
            size         => { type => 'str' }, 
            facility     => { type => 'str' }, 
            tag          => { type => 'str' }, 
            unixdomain   => { type => 'bool' }, 
            formatter    => { type => 'str' }, 
        },
    };
    return $schema;
}

1;
