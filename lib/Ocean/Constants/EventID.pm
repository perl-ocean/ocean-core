package Ocean::Constants::EventID;

use strict;
use warnings;

use constant UNKNOWN                        => 0;
use constant TOO_MANY_AUTH_ATTEMPT          => 1;
use constant SASL_AUTH_REQUEST              => 2;
use constant SASL_AUTH_COMPLETION           => 3;
use constant SASLAUTH_FAILURE               => 4;
use constant BIND_REQUEST                   => 5;
use constant BOUND_JID                      => 6;
use constant SEND_MESSAGE                   => 7;
use constant DELIVER_MESSAGE                => 8;
use constant BROADCAST_INITIAL_PRESENCE     => 9;
use constant BROADCAST_PRESENCE             => 10;
use constant DELIVER_PRESENCE               => 11;
use constant BROADCAST_UNAVAILABLE_PRESENCE => 12;
use constant DELIVER_UNAVAILABLE_PRESENCE   => 13;
use constant SILENT_DISCONNECTION           => 14;
use constant ROSTER_REQUEST                 => 15;
use constant DELIVER_ROSTER                 => 16;
use constant DELIVER_ROSTER_PUSH            => 17;
use constant VCARD_REQUEST                  => 18;
use constant DELIVER_VCARD                  => 19;
use constant HTTP_AUTH_REQUEST         => 20;
use constant HTTP_AUTH_COMPLETION      => 21;
use constant HTTP_AUTH_FAILURE         => 22;
use constant PUBLISH_EVENT                  => 23;
use constant DELIVER_PUBSUB_EVENT           => 24;


my $NAME_MAP = [
    'UNKNOWN',                     
    'TOO_MANY_AUTH_ATTEMPT',
    'SASL_AUTH_REQUEST',
    'SASL_AUTH_COMPLETION',
    'SASL_AUTH_FAILURE',                 
    'BIND_REQUEST',                 
    'BOUND_JID',                    
    'SEND_MESSAGE',                 
    'DELIVER_MESSAGE',              
    'BROADCAST_INITIAL_PRESENCE',   
    'BROADCAST_PRESENCE',           
    'DELIVER_PRESENCE',             
    'BROADCAST_UNAVAILABLE_PRESENCE',
    'DELIVER_UNAVAILABLE_PRESENCE', 
    'SILENT_DISCONNECTION',         
    'ROSTER_REQUEST',               
    'DELIVER_ROSTER',               
    'DELIVER_ROSTER_PUSH',          
    'VCARD_REQUEST',                
    'DELIVER_VCARD',                
    'HTTP_AUTH_REQUEST',
    'HTTP_AUTH_COMPLETION',
    'HTTP_AUTH_FAILURE',                 
    'PUBLISH_EVENT',
    'DELIVER_PUBSUB_EVENT',
];

sub get_name {
    my ($class, $id) = @_;
    return $NAME_MAP->[$id] || '';
}

1;
