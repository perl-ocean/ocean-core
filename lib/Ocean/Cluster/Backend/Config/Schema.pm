package Ocean::Cluster::Backend::Config::Schema;

use strict;
use warnings;

use Ocean::Config::Schema::Log;

sub config {
    my $schema = {
        type => 'map', 
        mapping => {
            worker => {
                type => 'map', 
                required => 1, 
                mapping => {
                    max_workers   => { type => 'int', required => 1 }, 
                    node_inboxes  => {
                        type => 'seq',
                        sequence => [
                            { 
                                type => 'map',
                                mapping => {
                                    node_id => { type => 'str', }, 
                                    address => { type => 'str', },
                                }, 
                            }, 
                        ],
                    },
                    broker_servers => {
                        type => 'seq', 
                        sequence => [
                            { type => 'str' }, 
                        ],
                    },
                    queue_name    => { type => 'str', required => 1 },
                    context_class => { type => 'str' }, 
                },
            },
            event_handler => {
                type     => 'map',
                required => 1,
                mapping  => {
                    worker     => { type => 'str', required => 1 }, 
                    node       => { type => 'str', required => 1 }, 
                    authen     => { type => 'str', required => 1 }, 
                    connection => { type => 'str', required => 1 }, 
                    people     => { type => 'str', required => 1 }, 
                    message    => { type => 'str', required => 1 }, 
                    room       => { type => 'str', required => 1 }, 
                    p2p        => { type => 'str', required => 1 }, 
                    pubsub     => { type => 'str', required => 1 }, 
                },
            },
            log => Ocean::Config::Schema::Log->config,
            muc => {
                type     => 'map',
                required => 0,
                mapping  => {
                    domain => { type => 'str', required => 1 },
                },
            },
            handler => {
                type => 'any', 
            },
        }
    };
    return $schema;
}

1;
