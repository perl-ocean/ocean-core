package Ocean::Jingle::TURN::Config::Schema;

use strict;
use warnings;

use Ocean::Config::Schema::Log;
use Ocean::Config::Schema::TLS;

sub config {
    my $schema = {
        type => 'map', 
        mapping => {
            server => {
                type     => 'map',
                required => 1,
                mapping  => {
                    domain        => { type => 'str', required => 1 }, 
                    host          => { type => 'str', required => 1 }, 
                    port          => { type => 'int', required => 1 }, 
                    receive_size  => { type => 'int', required => 1 }, 
                    pid_file      => { type => 'str' }, 
                    context_class => { type => 'str' }, 
                },
            },
            tcp => {
                type     => 'map',
                mapping  => {
                    port            => { type => 'int', required => 1 }, 
                    secure_port     => { type => 'int' }, 
                    backlog         => { type => 'int', required => 1 }, 
                    max_connection  => { type => 'int', required => 1 }, 
                    timeout         => { type => 'int', required => 1 }, 
                    max_read_buffer => { type => 'int', required => 1 }, 
                },
            },
            log => Ocean::Config::Schema::Log->config,
            tls => Ocean::Config::Schema::TLS->config,
            handler => {
                type => 'any',
            },
        },
    };
    return $schema;
}

1;
