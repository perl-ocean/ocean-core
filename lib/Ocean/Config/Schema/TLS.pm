package Ocean::Config::Schema::TLS;

use strict;
use warnings;

sub config {
    my $schema = {
        type     => 'map',
        mapping => {
            verify        => { type => 'str' }, 
            ca_file       => { type => 'str' }, 
            ca_path       => { type => 'str' }, 
            cert_file     => { type => 'str' }, 
            key_file      => { type => 'str' }, 
            cert          => { type => 'str' }, 
            cert_password => { type => 'str' }, 
            dh_file       => { type => 'str' }, 
            dh_single_use => { type => 'str' }, 
            cipher_list   => { type => 'str' }, 
        }, 
    };
    return $schema;
}

1;
