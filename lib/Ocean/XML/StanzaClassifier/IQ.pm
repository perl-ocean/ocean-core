package Ocean::XML::StanzaClassifier::IQ;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaClassifier';

use Ocean::Config;
use Ocean::Constants::EventType;
use Ocean::Constants::IQType;
use Ocean::Constants::StanzaErrorCondition;
use Ocean::Constants::StanzaErrorType;
use Ocean::JID;
use Ocean::XML::Namespaces qw(
    BIND
    SESSION
    ROSTER
    PING
    VCARD
    DISCO_INFO
    DISCO_ITEMS
    JINGLE_INFO
);

use List::MoreUtils qw(any);

sub classify {
    my ($class, $elem, $domain) = @_;

    my $to = $elem->attr('to') || $domain;
    my $to_jid = Ocean::JID->new($to);

    my $domains = Ocean::Config->instance->get(server => 'domain');

    if ((any { $to eq $_ } @$domains) || !$to_jid->resource) {
        return $class->classify_iq_toward_server($elem, $domain);

    } elsif( (!$to_jid->is_host) && $to_jid->resource ) {

        if (Ocean::Config->instance->has_section('muc')
         && Ocean::Config->instance->get(muc => q{domain}) eq $to_jid->domain) {
            return $class->classify_iq_toward_room_member($elem);
        } else {
            return $class->classify_iq_toward_user($elem, $domain);
        }
    }
}

sub classify_iq_toward_server {
    my ($class, $elem, $domain) = @_;

    if ($elem->get_first_element_ns(BIND, q{bind})) {
        return Ocean::Constants::EventType::BIND_REQUEST;
    }
    elsif ($elem->get_first_element_ns(SESSION, q{session})) {
        return Ocean::Constants::EventType::SESSION_REQUEST;
    }
    elsif ($elem->get_first_element_ns(ROSTER, q{query})) {

        # ignore response of roster-push
        return if ( $elem->attr('type') 
                 && $elem->attr('type') eq Ocean::Constants::IQType::RESULT);

        return Ocean::Constants::EventType::ROSTER_REQUEST;
    }
    elsif ($elem->get_first_element_ns(PING, q{ping})) {
        return Ocean::Constants::EventType::PING;
    }
    elsif ($elem->get_first_element_ns(VCARD, q{vCard})) {
        return Ocean::Constants::EventType::VCARD_REQUEST;
    }
    elsif ($elem->get_first_element_ns(DISCO_INFO, q{query})) {
        return $class->classify_iq_towerd_server_disco_info($elem, $domain);
    }
    elsif ($elem->get_first_element_ns(DISCO_ITEMS, q{query})) {
        return $class->classify_iq_towerd_server_disco_items($elem, $domain);
    }
    elsif ($elem->get_first_element_ns(JINGLE_INFO, q{query})) {
        return Ocean::Constants::EventType::JINGLE_INFO_REQUEST;
    }
    return;
}

sub classify_iq_towerd_server_disco_info {
    my ($self, $elem) = @_;

    my $config = Ocean::Config->instance;

    my $to = $elem->attr('to') || '';
    my $to_jid = Ocean::JID->new($to);

    return unless $to_jid && $to_jid->domain;

    my $domains = $config->get(server => 'domain');
    if (any { $to_jid->domain eq $_} @$domains) {
        return Ocean::Constants::EventType::DISCO_INFO_REQUEST;
    } 

    return unless $config->has_section('muc');

    my $muc_domain = $config->get(muc => 'domain');

    if ($to_jid->domain eq $muc_domain) {
        return $to_jid->node 
            ? Ocean::Constants::EventType::ROOM_INFO_REQUEST
            : Ocean::Constants::EventType::ROOM_SERVICE_INFO_REQUEST;
    }
    return;
}

sub classify_iq_towerd_server_disco_items {
    my ($self, $elem) = @_;

    my $config = Ocean::Config->instance;
    my $to = $elem->attr('to') || '';
    my $to_jid = Ocean::JID->new($to);

    return unless $to_jid && $to_jid->domain;

    my $domains = $config->get(server => 'domain');
    if (any { $to_jid->domain eq $_} @$domains) {
        return Ocean::Constants::EventType::DISCO_ITEMS_REQUEST;
    } 

    return unless $config->has_section('muc');

    my $muc_domain = $config->get(muc => 'domain');

    if ($to_jid->domain eq $muc_domain) {
        return $to_jid->node 
            ? Ocean::Constants::EventType::ROOM_MEMBERS_LIST_REQUEST
            : Ocean::Constants::EventType::ROOM_LIST_REQUEST;
    }
    return;
}

sub classify_iq_toward_room_member {
    my ($class, $elem)  = @_;
    if ($elem->get_first_element_ns(DISCO_INFO, q{query})) {
        return Ocean::Constants::EventType::ROOM_INFO_REQUEST;
    } else {
        return Ocean::Constants::EventType::SEND_IQ_TOWARD_ROOM_MEMBER;
    }
}

sub classify_iq_toward_user {
    my ($class, $elem)  = @_;
    return Ocean::Constants::EventType::SEND_IQ_TOWARD_USER;
}

1;
