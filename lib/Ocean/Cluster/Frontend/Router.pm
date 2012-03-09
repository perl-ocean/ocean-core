package Ocean::Cluster::Frontend::Router;

use strict;
use warnings;

use Ocean::Constants::EventType;
use Ocean::Error;
use Ocean::Cluster::Frontend::Router::Route;

use Storable;
use Log::Minimal;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _matchers => {}, 
        _default  => undef,
        _brokers  => {},
    }, $class;
    return $self;
}

sub register_broker {
    my ($self, $broker_id, $servers) = @_;

    Ocean::Error::InvalidRouteSetting->throw(
        message => q{register_broker - 'id' not found}
    ) unless $broker_id;
            
    Ocean::Error::InvalidRouteSetting->throw(
        message => q{register_broker - 'servers' not found}
    ) unless $servers;

    if (exists $self->{_brokers}{$broker_id}) {
        Ocean::Error::InvalidRouteSetting->throw(
            message => sprintf(
                q{register_broker - the broker_id '%s' already exists.}, 
                $broker_id),
        );
    }

    # TODO validation
    $servers = [ $servers ] unless ref $servers;

    $self->{_brokers}{$broker_id} = $servers;
}

sub setup_dispatcher {
    my ($self, $dispatcher) = @_;
    for my $broker_id ( keys %{ $self->{_brokers} } ) {
        $dispatcher->register_broker_client($broker_id, 
            $self->{_brokers}{$broker_id});
    }
}

=head2 event

    $router->event('message' => {
        broker => q{},
        queue  => q{},
    });

    $router->event('message' => sub {
        my $args = shift; 
        if ($args->{username} =~ //) {

        }
    });

    $router->event(['message', 'presence'] => sub {
        my $args     = shift; 
        my $event    = $args->{event};
        my $username = $args->{username};
    });

=cut

sub event_route {
    my ($self, $events, $matcher) = @_;
    if (not ref $events) {
        $events = [$events];
    } elsif (ref $events ne 'ARRAY') {
        die "Invalid Route Setting";
    }
    if (ref $matcher eq 'HASH') {
        my $hash = Storable::dclone($matcher);
        $matcher = sub { $hash };
    }
    elsif (ref $matcher ne 'CODE') {
        die "Invalid Route Setting";
    }
    for my $event ( @$events ) {
        my $evname = $self->_filter_event_name($event);
        die sprintf("Routing event name is invalid '%s'", $event)
            unless $evname;
        $self->{_matchers}{$event} = $matcher;
    }
    return $self;
}

# TODO added room events
my %EVENTS = (
    'node_init'                 => Ocean::Constants::EventType::NODE_INIT,
    'node_timer_report'         => Ocean::Constants::EventType::NODE_TIMER_REPORT,
    'node_exit'                 => Ocean::Constants::EventType::NODE_EXIT,
    'too_many_auth'             => Ocean::Constants::EventType::TOO_MANY_AUTH_ATTEMPT,
    'sasl_auth'                 => Ocean::Constants::EventType::SASL_AUTH_REQUEST,
    'sasl_password'             => Ocean::Constants::EventType::SASL_PASSWORD_REQUEST,
    'sasl_success_notification' => Ocean::Constants::EventType::SASL_SUCCESS_NOTIFICATION,
    'http_auth'                 => Ocean::Constants::EventType::HTTP_AUTH_REQUEST,
    'bind'                      => Ocean::Constants::EventType::BIND_REQUEST,
    'message'                   => Ocean::Constants::EventType::SEND_MESSAGE,
    'presence'                  => Ocean::Constants::EventType::BROADCAST_PRESENCE,
    'initial_presence'          => Ocean::Constants::EventType::BROADCAST_INITIAL_PRESENCE,
    'unavailable_presence'      => Ocean::Constants::EventType::BROADCAST_UNAVAILABLE_PRESENCE,
    'silent_disconnection'      => Ocean::Constants::EventType::SILENT_DISCONNECTION,
    'roster'                    => Ocean::Constants::EventType::ROSTER_REQUEST,
    'vcard'                     => Ocean::Constants::EventType::VCARD_REQUEST,
    'iq_toward_user'            => Ocean::Constants::EventType::SEND_IQ_TOWARD_USER,
);

my %REVERSED_EVENTS = reverse %EVENTS;

sub _filter_event_name {
    my ($self, $event) = @_;
    return $EVENTS{$event}
}

sub _filter_cannonical_event_name {
    my ($self, $event) = @_;
    return $REVERSED_EVENTS{$event}
}

sub default_route {
    my ($self, $matcher) = @_;
    if (ref $matcher eq 'HASH') {
        my $hash = Storable::dclone($matcher);
        $matcher = sub { $hash };
    }
    elsif (ref $matcher ne 'CODE') {
        die "Invalid Route Setting";
    }
    $self->{_default} = $matcher;
    return $self;
}

sub match {
    my ($self, $cannonical_event, $args) = @_;

    my $event = $self->_filter_cannonical_event_name($cannonical_event);
    die sprintf("Unkown event '%s'", $cannonical_event) unless $event;

    $args ||= +{};
    $args->{event} = $event;

    my $matcher = exists $self->{_matchers}{$event}
        ? $self->{_matchers}{$event}
        : $self->{_default};

    return unless $matcher;
    
    my $result = $matcher->($args);

    return unless $result;

    Ocean::Error::InvalidRouteSetting->throw(
        message => sprintf(
            "router matcher for evenet '%s' returns invalid format of value.", 
            $event) 
    ) unless (ref $result && ref $result eq 'HASH');

    Ocean::Error::InvalidRouteSetting->throw(
        message => sprintf(
            "'broker' param not found at router matcher for evenet '%s' .", 
            $event) 
    ) unless exists $result->{broker};

    my $broker = $result->{broker};

    Ocean::Error::InvalidRouteSetting->throw(
        message => sprintf(
            "unknown 'broker' is set for event '%s', maybe you forgot to do 'register_broker'", 
            $event) 
    ) unless exists $self->{_brokers}{$broker};

    Ocean::Error::InvalidRouteSetting->throw(
        message => sprintf(
            "'queue' param not found at router matcher for evenet '%s' .", 
            $event) 
    ) unless exists $result->{queue};

    my $queue = $result->{queue};

    my $route = Ocean::Cluster::Frontend::Router::Route->new({
        broker => $broker,     
        queue  => $queue,
    });

    return $route;
}

1;
