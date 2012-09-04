package Ocean::StreamComponent::IO::Encoder::Default;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::IO::Encoder';

use MIME::Base64;
use XML::Writer;
use Encode;
use Ocean::Util::XML qw(filter_xml_chars);

use Ocean::XML::Namespaces qw(
    STREAM
    STREAMS
    STANZAS
    CLIENT
    TLS
    SASL
    BIND
    SESSION
    ROSTER
    VCARD
    DISCO_INFO
    DISCO_ITEMS
);
use Ocean::Util::XML qw(escape_xml_char);
use Ocean::Stanza::DeliveryRequestFormatter::XML::Message;
use Ocean::Stanza::DeliveryRequestFormatter::XML::RoomInvitation;
use Ocean::Stanza::DeliveryRequestFormatter::XML::RoomInvitationDecline;
use Ocean::Stanza::DeliveryRequestFormatter::XML::Presence;
use Ocean::Stanza::DeliveryRequestFormatter::XML::Roster;
use Ocean::Stanza::DeliveryRequestFormatter::XML::DiscoInfo;
use Ocean::Stanza::DeliveryRequestFormatter::XML::DiscoItems;
use Ocean::Stanza::DeliveryRequestFormatter::XML::vCard;
use Ocean::Stanza::DeliveryRequestFormatter::XML::JingleInfo;
use Ocean::Stanza::DeliveryRequestFormatter::XML::RosterItem;
use Ocean::Stanza::DeliveryRequestFormatter::XML::PubSubEvent;
use Ocean::Stanza::DeliveryRequestFormatter::XML::MessageError;
use Ocean::Stanza::DeliveryRequestFormatter::XML::PresenceError;
use Ocean::Stanza::DeliveryRequestFormatter::XML::IQError;
use Ocean::Constants::IQType;
use Ocean::Constants::StanzaErrorType;
use Ocean::Constants::StanzaErrorCondition;
use Ocean::Constants::SASLErrorType;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _on_write  => $args{on_write} || sub {},
        _writer    => undef,
        _wbuf      => '',
        _in_stream => 0,
    }, $class;
    $self->initialize();
    return $self;
}

sub on_write {
    my ($self, $callback) = @_;
    $self->{_on_write} = $callback;
}

sub initialize {
    my $self = shift;
    $self->{_wbuf}  = '';
    $self->{_writer} = XML::Writer->new(
        OUTPUT     => \$self->{_wbuf},
        NAMESPACES => 1,
        UNSAFE     => 1,
    );
    $self->{_in_stream} = 0;
}

sub flush {
    my $self = shift;
    $self->{_on_write}->(
        Encode::encode_utf8(substr($self->{_wbuf}, 0, length($self->{_wbuf}), ''))
    );
    # refresh memory
    $self->{_wbuf} = "" unless $self->{_wbuf};
}

sub send_http_handshake {
    my ($self, $handshake) = @_;
    # do nothing
}

sub send_http_handshake_error {
    my ($self, $code, $type) = @_;
    # do nothing
}

sub send_closing_http_handshake {
    my ($self) = @_;
    # do nothing
}

sub send_initial_stream {
    my ($self, $id, $domain) = @_;
    my $w = $self->{_writer};
    #$w->xmlDecl(); this includes \n
    $self->{_wbuf} = '<?xml version="1.0"?>';
    $w->addPrefix(STREAM, 'stream');
    $w->addPrefix(CLIENT, '');
    $w->forceNSDecl(CLIENT, '');
    $w->startTag(
        [STREAM, 'stream'],
        from    => $domain,
        id      => $id,
        version => '1.0',
        'xml:lang' => 'en',
    );
    $self->flush();
    $self->{_in_stream} = 1;
}

sub send_end_of_stream {
    my $self = shift;
    return unless $self->{_in_stream};
    my $w = $self->{_writer};
    $w->endTag();
    $self->flush();
}

sub send_stream_error {
    my ($self, $type, $msg) = @_;
    return unless $self->{_in_stream};
    my $w = $self->{_writer};
    $w->startTag([STREAM, 'error']);
        $w->addPrefix(STREAMS, '');
        $w->emptyTag([STREAMS, $type]);
        if ($msg) {
            $w->startTag([STREAMS, 'text']);
            $w->characters(filter_xml_chars($msg));
            $w->endTag();
        }
    $w->endTag();
    $self->flush();
}

sub send_stream_features {
    my ($self, $features) = @_;
    my $w = $self->{_writer};
    $w->startTag([STREAM, 'features']);
    for my $feature ( @$features ) {
        $w->addPrefix($feature->[1], '');
        if (@$feature > 2) {
            $w->startTag([$feature->[1], $feature->[0]]);
            for my $param ( @{ $feature->[2] } ) {
                if (@$param > 1) {
                    $w->startTag([$feature->[1], $param->[0]]);
                    $w->characters(filter_xml_chars($param->[1]));
                    $w->endTag();
                } else {
                    $w->emptyTag([$feature->[1], $param->[0]]);
                }
            }
            $w->endTag();
        } else {
            $w->emptyTag([$feature->[1], $feature->[0]]);
        }
    }
    $w->endTag();
    $self->flush();
}

sub send_sasl_challenge {
    my ($self, $challenge) = @_;
    my $w = $self->{_writer};
    $w->addPrefix(SASL, '');
    $w->startTag([SASL, 'challenge']);
    $w->characters(MIME::Base64::encode_base64($challenge, ''));
    $w->endTag();
    $self->flush();
}

=head2 send_sasl_failure($type)

type - L<Ocean::Constants::SASLErrorType>

=cut

sub send_sasl_failure {
    my ($self, $type) = @_;
    $type ||= Ocean::Constants::SASLErrorType::NOT_AUTHORIZED;
    my $w = $self->{_writer};
    $w->addPrefix(SASL, '');
    $w->startTag([SASL, 'failure']);
        $w->emptyTag([SASL, $type]);
    $w->endTag();
    $self->flush();
}

sub send_sasl_success {
    my ($self) = @_;
    my $w = $self->{_writer};
    $w->addPrefix(SASL, '');
    $w->emptyTag([SASL, 'success']);
    $self->flush();
}

sub send_sasl_abort {
    my ($self) = @_;
    my $w = $self->{_writer};
    $w->addPrefix(SASL, '');
    $w->emptyTag([SASL, 'abort']);
    $self->flush();
}

sub send_tls_proceed {
    my ($self) = @_;
    my $w = $self->{_writer};
    $w->addPrefix(TLS, '');
    $w->emptyTag([TLS, 'proceed']);
    $self->flush();
}

sub send_tls_failure {
    my ($self) = @_;
    my $w = $self->{_writer};
    $w->addPrefix(TLS, '');
    $w->emptyTag([TLS, 'failure']);
    $self->flush();
}

sub send_presence {
    my ($self, $presence) = @_;
    my $w = $self->{_writer};
    $w->raw(Ocean::Stanza::DeliveryRequestFormatter::XML::Presence->format($presence));
    $self->flush();
}

sub send_unavailable_presence {
    my ($self, $from, $to) = @_;
    my $w = $self->{_writer};
    $w->addPrefix(CLIENT, '');
    $w->emptyTag(
        [CLIENT, 'presence'],
        from => $from,
        to   => $to,
        type => 'unavailable',
    );
    $self->flush();
}

sub send_message {
    my ($self, $message) = @_;
    my $w = $self->{_writer};
    $w->raw(Ocean::Stanza::DeliveryRequestFormatter::XML::Message->format($message));
    $self->flush();
}

sub send_room_invitation {
    my ($self, $invitation) = @_;
    my $w = $self->{_writer};
    $w->raw(Ocean::Stanza::DeliveryRequestFormatter::XML::RoomInvitation->format($invitation));
    $self->flush();
}

sub send_room_invitation_decline {
    my ($self, $decline) = @_;
    my $w = $self->{_writer};
    $w->raw(Ocean::Stanza::DeliveryRequestFormatter::XML::RoomInvitationDecline->format($decline));
    $self->flush();
}

sub send_pubsub_event {
    my ($self, $event) = @_;
    my $w = $self->{_writer};
    $w->raw(Ocean::Stanza::DeliveryRequestFormatter::XML::PubSubEvent->format($event));
    $self->flush();
}

sub send_message_error {
    my ($self, $error) = @_;
    my $w = $self->{_writer};
    $w->raw(Ocean::Stanza::DeliveryRequestFormatter::XML::MessageError->format($error));
    $self->flush();
}

sub send_presence_error {
    my ($self, $error) = @_;
    my $w = $self->{_writer};
    $w->raw(Ocean::Stanza::DeliveryRequestFormatter::XML::PresenceError->format($error));
    $self->flush();
}

sub send_iq_error {
    my ($self, $error) = @_;
    my $w = $self->{_writer};
    $w->raw(Ocean::Stanza::DeliveryRequestFormatter::XML::IQError->format($error));
    $self->flush();
}

sub send_roster_push {
    my ($self, $id, $domain, $to, $item) = @_;
    $self->send_iq(Ocean::Constants::IQType::SET, 
        $id, $domain, sub {
            my $w = shift;
            $w->addPrefix(ROSTER, '');
            $w->startTag([ROSTER, 'query']);
                $w->raw(Ocean::Stanza::DeliveryRequestFormatter::XML::RosterItem->format($item));
            $w->endTag();
        }, $to);
}

sub send_bind_result {
    my ($self, $id, $domain, $result) = @_;
    my $jid = $result->jid;
    $jid = $jid->as_string if $jid->isa('Ocean::JID');
    $self->send_iq(Ocean::Constants::IQType::RESULT, 
        $id, $domain, sub {
            my $w = shift;
            $w->addPrefix(BIND, '');
            $w->startTag([BIND, 'bind']);
                $w->startTag([BIND, 'jid']);
                $w->characters($jid);
                $w->endTag();
            $w->endTag();
        });
}

sub send_session_result {
    my ($self, $id, $domain) = @_;
    $self->send_iq(Ocean::Constants::IQType::RESULT, 
        $id, $domain, sub {
            my $w = shift;     
            $w->addPrefix(SESSION, '');
            $w->emptyTag([SESSION, 'session']);
        });
}

sub send_roster_result {
    my ($self, $id, $domain, $to, $roster) = @_;
    $self->send_iq(Ocean::Constants::IQType::RESULT, 
        $id, $domain, sub {
            my $w = shift;
            $w->addPrefix(ROSTER, '');
            $w->startTag([ROSTER, 'query']);
            $w->raw(Ocean::Stanza::DeliveryRequestFormatter::XML::Roster->format($roster)); 
            $w->endTag();
        }, $to);
}

sub send_pong {
    my ($self, $id, $domain, $to) = @_;
    $self->send_iq(Ocean::Constants::IQType::RESULT, 
        $id, $domain, undef, $to);
}

sub send_vcard {
    my ($self, $id, $to, $vcard) = @_;
    $self->send_iq(Ocean::Constants::IQType::RESULT, 
        $id, $vcard->jid, sub {
        my $w = shift;    
        $w->raw(Ocean::Stanza::DeliveryRequestFormatter::XML::vCard->format($vcard));
    }, $to);
}

sub send_iq_toward_user {
    my ($self, $id, $to, $query) = @_;
    $self->send_iq($query->type, 
        $id, $query->from->as_string, sub {
        my $w = shift;    
        $w->raw($query->raw);
    }, $to);
}

sub send_iq_toward_room_member {
    my ($self, $id, $to, $query) = @_;
    $self->send_iq($query->type,
        $id, $query->from->as_string, sub {
        my $w = shift;
        $w->raw($query->raw);
    }, $to);
}

sub send_jingle_info {
    my ($self, $id, $to, $info) = @_;
    $self->send_iq(Ocean::Constants::IQType::RESULT, 
        $id, $info->from->as_string, sub {
        my $w = shift;    
        $w->raw(Ocean::Stanza::DeliveryRequestFormatter::XML::JingleInfo->format($info));
    }, $to);
}

sub send_server_disco_info {
    my ($self, $id, $domain, $to, $info) = @_;
    $self->send_iq(Ocean::Constants::IQType::RESULT,
        $id, $domain, sub {
        my $w =shift; 
        $w->raw(Ocean::Stanza::DeliveryRequestFormatter::XML::DiscoInfo->format($info));
    }, $to);
}

sub send_server_disco_items {
    my ($self, $id, $domain, $to, $items) = @_;
    $self->send_iq(Ocean::Constants::IQType::RESULT,
        $id, $domain, sub {
        my $w = shift; 
        $w->raw(Ocean::Stanza::DeliveryRequestFormatter::XML::DiscoItems->format($items));
        #$w->addPrefix(DISCO_ITEMS, '');
        #$w->emptyTag([DISCO_ITEMS, 'query']);
    }, $to);
}

sub send_iq {
    my ($self, $type, $id, $from, $callback, $to) = @_;
    my $w = $self->{_writer};
    $w->addPrefix(CLIENT, '');
    my %attrs = (
        type => $type,
        id   => $id,
    );
    $attrs{from} = $from if $from;
    $attrs{to} = $to if $to;
    $w->startTag(
        [CLIENT, 'iq'],
        %attrs,
    );
    $callback->($w) if $callback;
    $w->endTag();
    $self->flush();
}

sub release {
    my $self = shift;
    $self->on_write(sub {});
}

1;
