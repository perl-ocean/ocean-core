package Ocean::Cluster::Frontend::Context;

use strict;
use warnings;

use parent 'Ocean::Context';

use Ocean::Cluster::SerializerFactory;
use Ocean::Cluster::Frontend::RouterEvaluator;

use Ocean::Constants::EventType;
use Ocean::Config;
use Ocean::Error;
use Ocean::JID;

use Ocean::Stanza::DeliveryRequestBuilder::SASLAuthCompletion;
use Ocean::Stanza::DeliveryRequestBuilder::SASLAuthFailure;
use Ocean::Stanza::DeliveryRequestBuilder::SASLPassword;
use Ocean::Stanza::DeliveryRequestBuilder::BoundJID;
use Ocean::Stanza::DeliveryRequestBuilder::ChatMessage;
use Ocean::Stanza::DeliveryRequestBuilder::Presence;
use Ocean::Stanza::DeliveryRequestBuilder::UnavailablePresence;
use Ocean::Stanza::DeliveryRequestBuilder::HTTPAuthCompletion;
use Ocean::Stanza::DeliveryRequestBuilder::HTTPAuthFailure;
use Ocean::Stanza::DeliveryRequestBuilder::Roster;
use Ocean::Stanza::DeliveryRequestBuilder::RosterItem;
use Ocean::Stanza::DeliveryRequestBuilder::vCard;
use Ocean::Stanza::DeliveryRequestBuilder::PubSubEvent;
use Ocean::Stanza::DeliveryRequestBuilder::PubSubEventItem;
use Ocean::Stanza::DeliveryRequestBuilder::TowardUserIQ;
use Ocean::Stanza::DeliveryRequestBuilder::RoomInvitation;
use Ocean::Stanza::DeliveryRequestBuilder::RoomInvitationDecline;
use Ocean::Stanza::DeliveryRequestBuilder::TowardRoomMemberIQ;
use Ocean::Stanza::DeliveryRequestBuilder::RoomMessage;
use Ocean::Stanza::DeliveryRequestBuilder::RoomInfo;
use Ocean::Stanza::DeliveryRequestBuilder::RoomList;
use Ocean::Stanza::DeliveryRequestBuilder::RoomListItem;
use Ocean::Stanza::DeliveryRequestBuilder::RoomMembersList;
use Ocean::Stanza::DeliveryRequestBuilder::RoomMembersListItem;

use Log::Minimal;
use Module::Load;

sub new {
    my ($class, %args) = @_;
    my $self = $class->SUPER::new(%args);
    $self->{_fetcher}    = $args{fetcher};
    $self->{_dispatcher} = $args{dispatcher};
    $self->{_serializer} = $args{serializer};
    return $self;
}

sub node_id {
    my $self = shift;
    return $self->config('node_id');
}

sub _create_fetcher {
    my ($self, $node_id, $config) = @_;

    my $fetcher_class = $config->{class}
        or die "fetcher class is not found";

    Module::Load::load($fetcher_class);

    unless ($fetcher_class->isa('Ocean::Cluster::Frontend::Fetcher')) {
        die sprintf(
            "%s is not sub-class of Ocean::Cluster::Frontend::Fetcher", 
            $fetcher_class);
    }

    my $args = $config->{config} || {};
    $args->{node_id} = $node_id;
    my $fetcher = $fetcher_class->new(%$args);
    return $fetcher;
}

sub _create_dispatcher {
    my ($self, $config) = @_;

    my $dispatcher_class = $config->{class}
        or die "dispatcher class is not found";

    Module::Load::load($dispatcher_class);

    unless ($dispatcher_class->isa('Ocean::Cluster::Frontend::Dispatcher')) {
        die sprintf(
            "%s is not sub-class of Ocean::Cluster::Frontend::Dispatcher", 
            $dispatcher_class);
    }

    my $args = $config->{config} || {};
    my $dispatcher = $dispatcher_class->new(%$args);
    return $dispatcher;
}

sub _create_serializer {
    my ($self, $type) = @_;
    $type ||= 'json';
    return Ocean::Cluster::SerializerFactory->new->create($type);
}

sub _create_router {
    my ($self, $router_file) = @_;
    return Ocean::Cluster::Frontend::RouterEvaluator->evaluate($router_file);
}

sub inbox_host { $_[0]->{_fetcher}->inbox_host }
sub inbox_port { $_[0]->{_fetcher}->inbox_port }

sub initialize {
    my $self = shift;

    $self->{_serializer} = 
        $self->_create_serializer( $self->config('serializer') )
            unless $self->{_serializer};

    $self->{_fetcher} = 
        $self->_create_fetcher( $self->node_id, $self->config('fetcher') )
            unless $self->{_fetcher};

    $self->{_fetcher}->on_fetch_event(sub {
        $self->on_fetcher_got_event(@_);
    });

    $self->{_dispatcher} = 
        $self->_create_dispatcher( $self->config('dispatcher') )
            unless $self->{_dispatcher};

    $self->{_router} = 
        $self->_create_router( $self->config('router') )
            unless $self->{_router};

    $self->{_router}->setup_dispatcher($self->{_dispatcher});
}

sub on_fetcher_got_event {
    my ($self, $data) = @_;

    infof("<Context> got job");

    my $event = $self->{_serializer}->deserialize($data);
    $self->_deliver_event($event);
}

my %DELIVERY_METHOD_MAP = (
    Ocean::Constants::EventType::SASL_AUTH_COMPLETION,
        'deliver_sasl_auth_completion',
    Ocean::Constants::EventType::SASL_AUTH_FAILURE,
        'deliver_sasl_auth_failure',
    Ocean::Constants::EventType::DELIVER_SASL_PASSWORD,
        'deliver_sasl_password',
    Ocean::Constants::EventType::HTTP_AUTH_COMPLETION,
        'deliver_http_auth_completion',
    Ocean::Constants::EventType::HTTP_AUTH_FAILURE,
        'deliver_http_auth_failure',
    Ocean::Constants::EventType::BOUND_JID,
        'deliver_bound_jid',
    Ocean::Constants::EventType::DELIVER_MESSAGE,
        'deliver_message',
    Ocean::Constants::EventType::DELIVER_PRESENCE,
        'deliver_presence',
    Ocean::Constants::EventType::DELIVER_UNAVAILABLE_PRESENCE,
        'deliver_unavailable_presence',
    Ocean::Constants::EventType::DELIVER_ROSTER,
        'deliver_roster',
    Ocean::Constants::EventType::DELIVER_VCARD,
        'deliver_vcard',
    Ocean::Constants::EventType::DELIVER_PUBSUB_EVENT,
        'deliver_pubsub_event',
    Ocean::Constants::EventType::DELIVER_IQ_TOWARD_USER,
        'deliver_iq_toward_user',
    Ocean::Constants::EventType::DELIVER_ROOM_INVITATION,
        'deliver_room_invitation',
    Ocean::Constants::EventType::DELIVER_ROOM_INVITATION_DECLINE,
        'deliver_room_invitation_decline',
    Ocean::Constants::EventType::DELIVER_IQ_TOWARD_ROOM_MEMBER,
        'deliver_iq_toward_room_member',
    Ocean::Constants::EventType::DELIVER_ROOM_MESSAGE,
        'deliver_room_message',
    Ocean::Constants::EventType::DELIVER_ROOM_INFO,
        'deliver_room_info',
    Ocean::Constants::EventType::DELIVER_ROOM_LIST,
        'deliver_room_list',
    Ocean::Constants::EventType::DELIVER_ROOM_MEMBERS_LIST,
        'deliver_room_members_list',
);

sub _delivery_method_map {
    my $self = shift;
    return \%DELIVERY_METHOD_MAP;
}

sub _deliver_event {
    my ($self, $event) = @_;

    my $type = $event->{type} || '';
    my $args = $event->{args} || {};

    infof('<Context> @delivery { event: %s }', $type);

    my $method = $self->_delivery_method_map->{$type};
    if ($method) {
        $self->$method($args);
    } else {
        warnf('<Context> unknown event type: %s', $type);
    }
}

sub post_job {
    my ($self, $type, $args) = @_;

    debugf('<Context> @post { event: %s } ', $type);

    my $data = $self->{_serializer}->serialize({ 
        type    => $type, 
        node_id => $self->node_id,
        args    => $args, 
    });

    my $route = $self->{_router}->match($type, $args);

    warnf("<Handler> route for event '%s' not found", $type)
        unless $route;

    $self->{_dispatcher}->dispatch(
        broker_id  => $route->broker,
        queue_name => $route->queue,
        data       => $data,
    );
}

sub deliver_sasl_auth_completion {
    my ($self, $args) = @_;

    my $stream_id  = $args->{stream_id};
    my $user_id    = $args->{user_id};
    my $username   = $args->{username};
    my $session_id = $args->{session_id};

    my $builder = 
        Ocean::Stanza::DeliveryRequestBuilder::SASLAuthCompletion->new;
    $builder->stream_id($stream_id);
    $builder->user_id($user_id);
    $builder->username($username);
    $builder->session_id($session_id);
    $self->deliver($builder->build());
}

sub deliver_sasl_password {
    my ($self, $args) = @_;

    my $stream_id = $args->{stream_id};
    my $password  = $args->{password};

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::SASLPassword->new;
    $builder->stream_id($stream_id);
    $builder->password($password);
    $self->deliver($builder->build());
}

sub deliver_http_auth_completion {
    my ($self, $args) = @_;

    my $stream_id  = $args->{stream_id};
    my $user_id    = $args->{user_id};
    my $username   = $args->{username};
    my $session_id = $args->{session_id};
    my $cookies    = $args->{cookies};

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::HTTPAuthCompletion->new;
    $builder->stream_id($stream_id);
    $builder->session_id($session_id);
    $builder->user_id($user_id);
    $builder->username($username);
    # TODO
    # $builder->add_cookie(foo => $cookie_value);
    # $builder->add_cookie(bar => { value => 'fugafuga', domain => 'xmpp.example.org', path => '/foo' });
    $self->deliver($builder->build());
}

sub deliver_sasl_auth_failure {
    my ($self, $args) = @_;

    my $stream_id = $args->{stream_id};

    my $builder = 
        Ocean::Stanza::DeliveryRequestBuilder::SASLAuthFailure->new;
    $builder->stream_id($stream_id);
    $self->deliver($builder->build());
}

sub deliver_http_auth_failure {
    my ($self, $args) = @_;

    my $stream_id = $args->{stream_id};

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::HTTPAuthFailure->new;
    $builder->stream_id($stream_id);
    $self->deliver($builder->build());
}

sub deliver_bound_jid {
    my ($self, $args) = @_;

    my $stream_id = $args->{stream_id};
    my $bound_jid = Ocean::JID->new($args->{jid});

    my $builder = 
        Ocean::Stanza::DeliveryRequestBuilder::BoundJID->new;
    $builder->stream_id($stream_id);
    $builder->jid($bound_jid);
    $builder->nickname($args->{nickname}) if exists $args->{nickname};
    $builder->photo_url($args->{photo_url}) if exists $args->{photo_url};
    $self->deliver($builder->build());
}

sub deliver_message {
    my ($self, $args) = @_;

    my $to_jid   = Ocean::JID->new($args->{to});
    my $from_jid = Ocean::JID->new($args->{from});

    my $builder = 
        Ocean::Stanza::DeliveryRequestBuilder::ChatMessage->new;
    $builder->to($to_jid);
    $builder->from($from_jid);
    $builder->body($args->{body});
    $builder->thread($args->{thread} || '');
    $builder->state($args->{state} || '');

    $self->deliver($builder->build());
}

sub deliver_pubsub_event {
    my ($self, $args) = @_;

    my $to_jid   = Ocean::JID->new($args->{to});
    my $from_jid = Ocean::JID->new($args->{from});
    my $items    = $args->{items} || [];
    my $node     = $args->{node};

    my $builder = 
        Ocean::Stanza::DeliveryRequestBuilder::PubSubEvent->new;

    $builder->from($from_jid);
    $builder->to($to_jid);
    $builder->node($node);
    for my $item ( @$items ) {
        my $item_builder = 
            Ocean::Stanza::DeliveryRequestBuilder::PubSubEventItem->new;
        $item_builder->id( $item->{id} );
        $item_builder->name( $item->{name} );
        $item_builder->namespace( $item->{namespace} );
        for my $key ( keys %{ $item->{fields} } ) {
            $item_builder->add_field( $key, $item->{fields}{$key} );
        }
        $builder->add_item_builder( $item_builder );
    }
    $self->deliver($builder->build());
}

sub deliver_presence {
    my ($self, $args) = @_;

    my $to_jid   = Ocean::JID->new($args->{to});
    my $from_jid = Ocean::JID->new($args->{from});

    my $builder =
        Ocean::Stanza::DeliveryRequestBuilder::Presence->new;
    $builder->from($from_jid);
    $builder->to($to_jid);
    $builder->show($args->{show});
    $builder->status($args->{status});
    $builder->image_hash($args->{image_hash})
        if $args->{image_hash};

    $self->deliver($builder->build());
}

sub deliver_unavailable_presence {
    my ($self, $args) = @_;

    my $to_jid   = Ocean::JID->new($args->{to});
    my $from_jid = Ocean::JID->new($args->{from});

    my $builder =
        Ocean::Stanza::DeliveryRequestBuilder::UnavailablePresence->new;
    $builder->from($from_jid);
    $builder->to($to_jid);

    $self->deliver($builder->build());
}

sub deliver_roster {
    my ($self, $args) = @_;

    my $request_id = $args->{request_id};
    my $to_jid     = Ocean::JID->new($args->{to});
    my $items      = $args->{items} || [];

    my $builder = 
        Ocean::Stanza::DeliveryRequestBuilder::Roster->new;
    $builder->to($to_jid);
    $builder->request_id($request_id);

    for my $item (@$items) {

        my $item_builder =
            Ocean::Stanza::DeliveryRequestBuilder::RosterItem->new;

        $item_builder->jid($item->{jid});
        $item_builder->nickname($item->{nickname});
        $item_builder->subscription($item->{subscription});
        $item_builder->photo_url($item->{photo_url})
            if exists $item->{photo_url};

        $builder->add_item_builder($item_builder);
    }

    $self->deliver($builder->build());
}

sub deliver_vcard {
    my ($self, $args) = @_;

    # TODO validation
    my $to_jid     = Ocean::JID->new($args->{to});
    my $request_id = $args->{request_id};

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::vCard->new;
    $builder->to($to_jid);
    $builder->request_id($request_id);
    $builder->jid($args->{jid});
    $builder->nickname($args->{nickname});

    $builder->photo_url($args->{photo_url}) 
        if exists $args->{photo_url};
    $builder->photo_content_type($args->{photo_content_type}) 
        if exists $args->{photo_content_type};
    $builder->photo($args->{photo})
        if exists $args->{photo};

    $self->deliver($builder->build());
}

sub deliver_iq_toward_user {
    my ($self, $args) = @_;

    # TODO validation
    my $to_jid   = Ocean::JID->new($args->{to});
    my $from_jid = Ocean::JID->new($args->{from});

    my $request_id = $args->{request_id};

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::TowardUserIQ->new;
    $builder->to($to_jid);
    $builder->from($from_jid);
    $builder->request_id($request_id);
    $builder->raw($args->{raw});
    $builder->query_type($args->{type});

    $self->deliver($builder->build());
}

sub deliver_room_invitation {
    my ($self, $args) = @_;

    my $to_jid = Ocean::JID->new($args->{to});
    my $from_jid = Ocean::JID->new($args->{invitor});
    my $room = Ocean::JID->new($args->{from})->node;

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::RoomInvitation->new;
    $builder->room($room);
    $builder->from($from_jid);
    $builder->to($to_jid);
    $builder->reason($args->{reason});
    $builder->thread($args->{thread});

    $self->deliver($builder->build());
}

sub deliver_room_invitation_decline {
    my ($self, $args) = @_;

    my $to_jid = Ocean::JID->new($args->{to});
    my $from_jid = Ocean::JID->new($args->{decliner});
    my $room = Ocean::JID->new($args->{from})->node;

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::RoomInvitationDecline->new;
    $builder->room($room);
    $builder->from($from_jid);
    $builder->to($to_jid);
    $builder->reason($args->{reason});
    $builder->thread($args->{thread});

    $self->deliver($builder->build());
}

sub deliver_iq_toward_room_member {
    my ($self, $args) = @_;

    my $to_jid = Ocean::JID->new($args->{to});
    my $from_jid = Ocean::JID->new($args->{from});

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::TowardRoomMemberIQ->new;
    $builder->to($to_jid);
    $builder->from($from_jid);
    $builder->query_type($args->{type});
    $builder->request_id($args->{request_id});
    $builder->raw($args->{raw});

    $self->deliver($builder->build());
}

sub deliver_room_message {
    my ($self, $args) = @_;

    my $to_jid   = Ocean::JID->new($args->{to});
    my $from_jid = Ocean::JID->new($args->{from});

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::RoomMessage->new;
    $builder->to($to_jid);
    $builder->from($from_jid);
    $builder->body($args->{body});
    $builder->thread($args->{thread} || '');
    $builder->state($args->{state} || '');

    $self->deliver($builder->build());
}

sub deliver_room_info {
    my ($self, $args) = @_;

    my $to_jid = Ocean::JID->new($args->{to});
    my $room   = $args->{identities}[0];

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::RoomInfo->new;
    $builder->request_id($args->{id});
    $builder->to($to_jid);
    $builder->room_name($room->{name});
    $builder->room_nickname($room->{name});

    $self->deliver($builder->build());
}

sub deliver_room_list {
    my ($self, $args) = @_;

    my $to_jid = Ocean::JID->new($args->{to});

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::RoomList->new;
    $builder->request_id($args->{id});
    $builder->to($to_jid);

    my @rooms = @{$args->{items}};
    for my $room ( @rooms ) {
        my $name_jid = Ocean::JID->new($room->{name});
        my $item = Ocean::Stanza::DeliveryRequestBuilder::RoomListItem->new;
        $item->room_name($name_jid->node);
        $item->room_nickname($name_jid->as_string);
        $builder->add_item_builder($item);
    }

    $self->deliver($builder->build());
}

sub deliver_room_members_list {
    my ($self, $args) = @_;

    my $to_jid   = Ocean::JID->new($args->{to});
    my $room_jid = Ocean::JID->new($args->{from});

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::RoomMembersList->new;
    $builder->request_id($args->{id});
    $builder->to($to_jid);
    $builder->room($room_jid->node);

    my @members = @{$args->{items}};
    for my $member ( @members ) {
        my $member_jid = Ocean::JID->new($member->{jid});
        my $item = Ocean::Stanza::DeliveryRequestBuilder::RoomMembersListItem->new;
        $item->jid($member_jid);
        $item->name($member->{name});
        $builder->add_item_builder($item);
    }

    $self->deliver($builder->build());
}
1;
