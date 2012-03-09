package Ocean::JSON::StanzaClassifier;

use strict;
use warnings;

use Ocean::Constants::EventType;

sub classify {
    my ($self, $obj) = @_;
    if (exists $obj->{stream}) {
        return Ocean::Constants::EventType::STREAM_INIT;
    }
    elsif (exists $obj->{auth}) {
        return Ocean::Constants::EventType::SASL_AUTH_REQUEST;
    }
    elsif (exists $obj->{message}) {
        return Ocean::Constants::EventType::SEND_MESSAGE;
    }
    elsif (exists $obj->{presence}) {
        return Ocean::Constants::EventType::BROADCAST_PRESENCE;
    }
    elsif (exists $obj->{bind}) {
        return Ocean::Constants::EventType::BIND_REQUEST;
    } 
    elsif (exists $obj->{session}) {
        return Ocean::Constants::EventType::SESSION_REQUEST;
    } 
    elsif (exists $obj->{roster}) {
        return Ocean::Constants::EventType::ROSTER_REQUEST;
    } 
    elsif (exists $obj->{vcard}) {
        return Ocean::Constants::EventType::VCARD_REQUEST;
    } 
    elsif (exists $obj->{ping}) {
        return Ocean::Constants::EventType::PING;
    } 
    return;
}

1;
