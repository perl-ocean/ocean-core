package Ocean::Jingle::STUN::Server;

use strict;
use warnings;

use Ocean::Config;
use Ocean::Jingle::STUN::AddressFamilyType;
use Ocean::Jingle::STUN::AttributeType;
use Ocean::Jingle::STUN::ClassType;
use Ocean::Jingle::STUN::Entity;
use Ocean::Jingle::STUN::ErrorCode;
use Ocean::Jingle::STUN::MessageReader;
use Ocean::Jingle::STUN::MessageBuilder;
use Ocean::Jingle::STUN::MethodType;
use Ocean::Jingle::STUN::TCPConnection;
use Ocean::Jingle::STUN::TransportType;

use Ocean::Jingle::STUN::Attribute::XORMappedAddress;
use Ocean::Jingle::STUN::Attribute::UnknownAttributes;
use Ocean::Jingle::STUN::Attribute::ErrorCode;
use Ocean::Jingle::STUN::Attribute::Software;

use AnyEvent;
use Log::Minimal;
use Try::Tiny;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _context                => $args{context},
        _daemonizer             => $args{daemonizer},
        _signal_handler         => $args{signal_handler},
        _udp_transport          => $args{udp_transport},
        _tcp_listener           => $args{tcp_listener},
        _tcp_tls_listener       => $args{tcp_tls_listener},
        _tcp_connection_manager => $args{tcp_connection_manager},
        _attribute_codec_store  => $args{attribute_codec_store},
    }, $class;
    return $self;
}

sub run {
    my $self = shift;
    $self->initialize();
    $self->start();
    $self->wait();
    $self->finalize();
}

sub initialize {
    my $self = shift;

    $self->{_context}->set_delegate($self);
    $self->{_signal_handler}->set_delegate($self);
    $self->{_udp_transport}->set_delegate($self);
    $self->{_tcp_listener}->set_delegate($self);
    $self->{_tcp_tls_listener}->set_delegate($self);
    $self->{_tcp_connection_manager}->set_delegate($self);

    $self->{_context}->initialize();
    $self->{_daemonizer}->initialize();
}

sub start {
    my $self = shift;
    $self->{_exit_guard} = AE::cv;
    $self->{_exit_guard}->begin();
    $self->{_signal_handler}->setup();

    $self->{_udp_transport}->start();
    $self->{_tcp_listener}->start();
    $self->{_tcp_tls_listener}->start();
}

sub wait {
    my $self = shift;
    $self->{_exit_guard}->recv();
}

sub finalize {
    my $self = shift;
    $self->{_context}->finalize();
    $self->{_daemonizer}->finalize();
    infof("<Server> exit");
}

sub on_signal_quit {
    my $self = shift;
    $self->shutdown();
}

sub on_tcp_listener_accept {
    my ($self, $address, $client_socket) = @_;
    unless ($self->_verify_server_stats()) {
        $client_socket->shutdown();
        return;
    }
    $self->_establish_connection($address, $client_socket);
    $self->{_exit_guard}->begin();
}

sub _report_current_connection_count {
    my $self = shift;
    my $counter = $self->{_tcp_connection_manager}->get_current_connection_counter();
    if ($counter == 0) {
        infof("<Server> Now this server has no client connection");
    } elsif ($counter == 1) {
        infof("<Server> Now this server is connected to one single stream");
    } else {
        infof("<Server> Now this server is connected to %d streams", 
            $counter);
    }
}

sub _report_total_connection_count {
    my $self = shift;
    my $total_counter = 
        $self->{_tcp_connection_manager}->get_total_connection_counter();
    if ($total_counter == 1) {
        infof("<Server> This is 1st stream in total as of this server started.");
    } elsif ($total_counter == 2) {
        infof("<Server> This is 2nd stream in total as of this server started.");
    } elsif ($total_counter == 3) {
        infof("<Server> This is 3rd stream in total as of this server started.");
    } else {
        infof("<Server> This is %dth stream in total as of this server started.", 
            $total_counter);
    }
}

sub _verify_server_stats {
    my $self = shift;
    if ($self->{_tcp_connection_manager}->get_current_connection_counter() + 1 > 
        Ocean::Config->instance->get(tcp => 'max_connection') ) {
        warnf("<Server> Connection not accepted - over capacity");
        return 0;
    }
    return 1;
}

sub _establish_connection {
    my ($self, $address, $client_socket) = @_;

    my $connection = Ocean::Jingle::STUN::TCPConnection->new(
        address => $address, 
        socket  => $client_socket,
    );

    $self->{_tcp_connection_manager}->register_connection($connection);

    infof("<Server> has registered the connection");
    $self->_report_current_connection_count();
    $self->_report_total_connection_count();
}

sub on_tcp_listener_prepare {
    my ($self, $sock, $host, $port) = @_;

    $host ||= 'localhost';
    infof("<Server> started listening on %s:%d", $host, $port);
}

sub on_transport_bound {
    my ($self, $host, $port) = @_;
    infof("<Server> bound UDP transport on %s:%d", $host, $port);
}

sub on_transport_received_message {
    my ($self, $host, $port, $bytes) = @_;

    $self->on_message(Ocean::Jingle::STUN::TransportType::UDP, 
        $host, $port, $bytes);

}

sub on_transport_error {
    my ($self, $fatal, $message) = @_;
    if ($fatal) {
        critf('<Server> Transport Error: %s', $message || '');
    } else {
        warnf('<Server> Transport Error: %s', $message || '');
    }
}

sub on_relayed_transport_received_message {
    my ($self, $allocaation_id, $host, $port, $bytes) = @_;
    my $allocation = $self->{_context}->get_allocation_by_id($allocaation_id);
}

sub on_relayed_transport_error {
    my ($self, $fatal, $message) = @_;
}

sub on_relayed_transport_bound {
    my ($self, $host, $port) = @_;
    infof("<Server> bound UDP transport on %s:%d", $host, $port);
}

sub on_message {
    my ($self, $proto, $host, $port, $bytes) = @_;

    my $entity = Ocean::Jingle::STUN::Entity->new({
        protocol => $proto,     
        host     => $host,
        port     => $port,
    });

    my $msg = Ocean::Jingle::STUN::MessageReader->new(
        attribute_codec_store => $self->{_attribute_codec_store}
    )->read($bytes);

    unless ($msg) {
        infof('<Server> <Transport:%s:%s:%d> @bad_message', 
            $proto, $host, $port);
        return;
    }

    if (   $msg->has_unknown_attributes 
        && $msg->class eq Ocean::Jingle::STUN::ClassType::REQUEST ) 
    {
        infof('<Server> <Transport:%s:%s:%d> @unknown_attributes', 
            $proto, $host, $port);
        $self->deliver_unknown_attributes_error(
            $entity, $msg->method, $msg->transaction_id, 
            $msg->unknown_attributes);
        return;
    }

    infof('<Server> <Transport:%s:%s:%d> @message { class:%s, method:%s }', 
        $proto, $host, $port, $msg->class, $msg->method );

    if ($msg->class eq Ocean::Jingle::STUN::ClassType::REQUEST) {
        $self->on_request_message($entity, $msg);
    }
    elsif ($msg->class eq Ocean::Jingle::STUN::ClassType::INDICATION) {
        $self->on_indication_message($entity, $msg);
    }
    else {
        infof('<Server> <Transport:%s:%d> invalid message class: %s', 
            $host, $port, $msg->class);
    }

}

sub on_request_message {
    my ($self, $entity, $msg) = @_;

    # authenticate
    # sign message

    return unless ($msg->class  eq Ocean::Jingle::STUN::ClassType::REQUEST
                && $msg->method eq Ocean::Jingle::STUN::MethodType::BINDING);

    my $builder = Ocean::Jingle::STUN::MessageBuilder->new(
        class                 => Ocean::Jingle::STUN::ClassType::RESPONSE_SUCCESS, 
        method                => $msg->method, 
        transaction_id        => $msg->transaction_id,
        attribute_codec_store => $self->{_attribute_codec_store},
    );

    my $attr = Ocean::Jingle::STUN::Attribute::XORMappedAddress->new;
    $attr->set(address => $entity->host);
    $attr->set(port    => $entity->port);
    $attr->set(family  => Ocean::Jingle::STUN::AddressFamilyType::IPV4);
    $builder->add_attribute($attr);

    my $res = $builder->build();
    unless ($res) {
        warnf('<Server> failed to build message');
        return;
    }

    debugf('<Server> @response, { message: %s }', 
        unpack('H*', $res));

    $self->deliver_message($entity, $builder->build());
}

sub on_indication_message {
    my ($self, $sender, $msg) = @_;
    # not supported on simple STUN server.
}

sub on_connection_received_message {
    my ($self, $host, $port, $bytes) = @_;
    $self->on_message(Ocean::Jingle::STUN::TransportType::TCP, 
        $host, $port, $bytes);
}

sub deliver_unknown_attributes_error {
    my ($self, $entity, $method, $transaction_id, $attributes) = @_;

    my $builder = Ocean::Jingle::STUN::MessageBuilder->new(
        class          => Ocean::Jingle::STUN::ClassType::RESPONSE_ERROR, 
        method         => $method,
        transaction_id => $transaction_id,
    );

    my $error = Ocean::Jingle::STUN::Attribute::ErrorCode->new;
    $error->set(code => Ocean::Jingle::STUN::ErrorCode::UNKNOWN_ATTRIBUTE);
    $builder->add_attribute($error);

    my $software = Ocean::Jingle::STUN::Attribute::Software->new;
    $software->set(software => q{Ocean STUN Server/1.0.0});
    $builder->add_attribute($software);

    my $unknown = Ocean::Jingle::STUN::Attribute::UnknownAttributes->new;
    for my $attr_type ( @{ $attributes } ) {
        $unknown->add_attribute($attr_type);
    }
    $builder->add_attribute($unknown);

    $self->deliver_message($entity, $builder->build());
}

sub deliver_message {
    my ($self, $entity, $bytes) = @_;
    if ($entity->protocol eq Ocean::Jingle::STUN::TransportType::UDP) {
        $self->{_udp_transport}->send(
            $entity->host, $entity->port, $bytes);
    } elsif ($entity->protocol eq Ocean::Jingle::STUN::TransportType::TCP) {
        $self->{_tcp_connection_manager}->deliver(
            $entity->host, $entity->port, $bytes);
    }
}

sub on_connection_disconnected {
    my $self = shift;
    $self->{_exit_guard}->end();
    infof("<Server> A connection disconnected.");
    #$self->_report_current_connection_count();
}

sub shutdown {
    my $self = shift;

    infof("<Server> started shutdown...");
    $self->{_tcp_listener}->stop();
    $self->{_tcp_tls_listener}->stop();
    $self->{_udp_transport}->stop();

    infof("<Server> stopped listening");
    $self->{_tcp_connection_manager}->disconnect_all();
    $self->{_exit_guard}->end();
}

sub release {
    my $self = shift;
    if ($self->{_tcp_connection_manager}) {
        $self->{_tcp_connection_manager}->release();
        delete $self->{_tcp_connection_manager};
    }
    if ($self->{_udp_transport}) {
        $self->{_udp_transport}->release();
        delete $self->{_udp_transport};
    }
    if ($self->{_tcp_listener}) {
        $self->{_tcp_listener}->release();
        delete $self->{_tcp_listener};
    }
    if ($self->{_tcp_tls_listener}) {
        $self->{_tcp_tls_listener}->release();
        delete $self->{_tcp_tls_listener};
    }
    if ($self->{_message_handler}) {
        $self->{_message_handler}->release();
        delete $self->{_message_handler};
    }
    if ($self->{_context}) {
        $self->{_context}->release();
        delete $self->{_context};
    }
    if ($self->{_signal_handler}) {
        $self->{_signal_handler}->release();
        delete $self->{_signal_handler};
    }
}

sub DESTROY {
    my $self = shift;
    $self->release();
}

1;
