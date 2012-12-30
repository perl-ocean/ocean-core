package Ocean::XML::StanzaClassifier::Message;

use strict;
use warnings;

use parent 'Ocean::XML::StanzaClassifier';
use Ocean::Config;
use Ocean::Constants::EventType;
use Ocean::JID;
use Ocean::XML::Namespaces qw(MUC_USER);

use Log::Minimal;
use List::MoreUtils qw(any);

sub classify {
    my ($self, $elem) = @_;

    my $to = $elem->attr('to');
    return unless $to;
    my $to_jid = Ocean::JID->new($to);
    return unless $to_jid;

    my $config = Ocean::Config->instance;

    my $domains = $config->get(server => q{domain});

    my $type = $elem->attr('type') || 'chat';

    if (any { $to_jid->domain eq $_ } @$domains) {

        if ($type eq 'normal' || $type eq 'chat') {
            return Ocean::Constants::EventType::SEND_MESSAGE;
        } else {
            warnf("<Stream> <Decoder> unsupported message-type: %s", $type);
            return;
        }
    }

    if (   $config->has_section('muc') 
        && $to_jid->domain eq $config->get(muc => q{domain})) {

        my $x = $elem->get_first_element_ns(MUC_USER, 'x');

        if ($x) {

            my $invite = $x->get_first_element('invite');
            return Ocean::Constants::EventType::ROOM_INVITATION 
                if $invite;

            my $decline = $x->get_first_element('decline');
            return Ocean::Constants::EventType::ROOM_INVITATION_DECLINE 
                if $decline;
        }
        

        if ($type eq 'groupchat') {
            return Ocean::Constants::EventType::SEND_ROOM_MESSAGE;
        } else {
            # ignore 'headline' or other from client
            warnf("<Stream> <Decoder> unsupported message-type: %s", $type);
            return;
        }
    }
}

1;
