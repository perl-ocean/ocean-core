package Ocean::XML::StanzaClassifier::Presence;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaClassifier';
use Ocean::Constants::EventType;
use Ocean::Constants::PresenceType;
use Ocean::Config;
use Ocean::JID;

sub classify {
    my ($self, $elem) = @_;

    my $to = $elem->attr('to');

    unless ($to) {
        return $self->classify_boadcast_presence($elem);
    }

    my $to_jid = Ocean::JID->new($to);
    my $domain = $to_jid->domain;

    my $config = Ocean::Config->instance;
    if (   $domain 
        && $config->has_section('muc')
        && $config->get(muc => 'domain') eq $domain) {

        return $self->classify_muc_presence($elem);

    } else {

        return $self->classify_direct_presence($elem);

    }
}

sub classify_boadcast_presence {
    my ($self, $elem) = @_;

    my $presence_type = $elem->attr('type') 
        || Ocean::Constants::PresenceType::AVAILABLE;

    if ($presence_type eq Ocean::Constants::PresenceType::AVAILABLE) {

        return Ocean::Constants::EventType::BROADCAST_PRESENCE;

    } elsif ($presence_type eq Ocean::Constants::PresenceType::UNAVAILABLE) {

        return Ocean::Constants::EventType::BROADCAST_UNAVAILABLE_PRESENCE;
    } 
}

sub classify_direct_presence {
    my ($self, $elem) = @_;
    # not supported yet
    return;
}

sub classify_muc_presence {
    my ($self, $elem) = @_;

    my $presence_type = $elem->attr('type') 
        || Ocean::Constants::PresenceType::AVAILABLE;

    if ($presence_type eq Ocean::Constants::PresenceType::AVAILABLE) {

        return Ocean::Constants::EventType::ROOM_PRESENCE;

    } elsif ($presence_type eq Ocean::Constants::PresenceType::UNAVAILABLE) {

        return Ocean::Constants::EventType::LEAVE_ROOM_PRESENCE;
    } 

    return;
}

1;
