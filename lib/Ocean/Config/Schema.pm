package Ocean::Config::Schema;

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
                    type            => { type => 'str', required => 1 }, 
                    domain          => { type => 'str', required => 1 }, 
                    host            => { type => 'str', required => 1 }, 
                    port            => { type => 'int', required => 1 }, 
                    backlog         => { type => 'int', required => 1 }, 
                    max_connection  => { type => 'int', required => 1 }, 
                    timeout         => { type => 'int', required => 1 }, 
                    max_read_buffer => { type => 'int', required => 1 }, 
                    report_interval => { type => 'int', required => 1 }, 
                    pid_file        => { type => 'str' }, 
                    context_class   => { type => 'str' }, 
                    use_stanza_counter        => { type => 'bool' }, 
                    stanza_counter_expiration => { type => 'int'  },
                    max_stanza_count          => { type => 'int'  }, 
                },
            },
            event_handler => {
                type     => 'map',
                required => 1,
                mapping  => {
                    node       => { type => 'str', required => 1 }, 
                    authen     => { type => 'str', required => 1 }, 
                    connection => { type => 'str', required => 1 }, 
                    people     => { type => 'str', required => 1 }, 
                    message    => { type => 'str', required => 1 }, 
                    room       => { type => 'str', required => 1 }, 
                    p2p        => { type => 'str', required => 1 }, 
                },
            },
            http => {
                type => 'map',
                mapping => {
                    pending_timeout    => { type => 'int'  }, 
                    path               => { type => 'str'  }, 
                    websocket_protocol => { type => 'str'  }, 
                    websocket_mask     => { type => 'bool' }, 
                },
            },
            log => Ocean::Config::Schema::Log->config,
            sasl => {
                type     => 'map',
                required => 1,
                mapping  => {
                    max_attempt => {
                        type => 'int', 
                    },
                    mechanisms => { 
                        type     => 'seq', 
                        required => 1,
                        sequence => [
                            { type => 'str' } 
                        ],
                    }, 
                },
            },
            muc => {
                type     => 'map',
                required => 0,
                mapping  => {
                    domain => { type => 'str', required => 1 },
                },
            },
            tls => Ocean::Config::Schema::TLS->config,
            handler => {
                type => 'any',
            },
        },
    };
    return $schema;
}

1;
