package Ocean::ServerComponent::Listener::AESocket;

use strict;
use warnings;

use parent 'Ocean::ServerComponent::Listener';

use Ocean::Config;
use Ocean::StreamComponent::IO::Socket::AEHandleAdapter;
use Ocean::Util::TLS;

use AnyEvent::Socket;
use AnyEvent::Handle;
use Log::Minimal;
# use Socket ();

# use constant DEFAULT_KEEP_IDLE     => 60;
# use constant DEFAULT_KEEP_INTERVAL => 10;
# use constant DEFAULT_KEEP_COUNT    =>  3;

sub start {
    my $self = shift;
    $self->{_listener} = tcp_server(
        $self->{_host}, 
        $self->{_port}, 
        sub {
            my ($sock, $host, $port) = @_;
            $self->_on_accept($sock, $host, $port);
        },
        sub {
            $self->{_delegate}->on_listener_prepare(@_);
            return $self->{_backlog};
        }
    );
}

#sub _set_sock_options {
#    my ($self, $sock) = @_;
#
#    if ($self->{keepalive}) {
#
#        my $keep_idle     = $self->{keep_idle}     || DEFAULT_KEEP_IDLE;
#        my $keep_interval = $self->{keep_interval} || DEFAULT_KEEP_INTERVAL;
#        my $keep_count    = $self->{keep_count}    || DEFAULT_KEEP_COUNT;
#
#        eval {
#            local $SIG{__DIE__};
#
#            setsockopt($sock, 
#                Socket::SOL_SOCKET(),
#                Socket::SO_KEEPALIVE(),
#                1);
#
#            setsockopt($sock, 
#                Socket::IT_PROTO_TCP(), 
#                Socket::TCP_KEEPIDLE(),
#                int($keep_idle));
#
#            setsockopt($sock, 
#                Socket::IT_PROTO_TCP(), 
#                Socket::TCP_KEEPINTVAL(), 
#                int($keep_interval));
#
#            setsockopt($sock, 
#                Socket::IT_PROTO_TCP(),
#                Socket::TCP_KEEPCNT(),
#                int($keep_count));
#        };
#    }
#}

sub _create_handle {
    my ($self, $sock) = @_;

    my %params = (
        fh       => $sock, 
        autocork => 1,
        no_delay => 1,
        rbuf_max => $self->{_max_read_buffer},
        timeout  => $self->{_timeout},
        wtimeout => $self->{_timeout_preauth},
    );

    if ( Ocean::Util::TLS::require_initialtls() ) {
        $params{tls}     = 'accept';
        $params{tls_ctx} = Ocean::Config->instance->get('tls');
    }

    return AnyEvent::Handle->new(%params);
}

sub _create_adapter {
    my ($self, $host, $port, $handle) = @_;
    return Ocean::StreamComponent::IO::Socket::AEHandleAdapter->new(
        host   => $host,
        port   => $port,
        handle => $handle,
    );
}

sub _on_accept {
    my ($self, $sock, $host, $port) = @_;

    infof("<Server> Here comes new connection %s:%d",
        $host, $port);

    # $self->_set_sock_options($sock);

    my $handle = $self->_create_handle($sock); 

    my $client_socket =  $self->_create_adapter($host, $port, $handle);

    my $client_id = fileno($sock);

    $self->{_delegate}->on_listener_accept(
        $client_id,  $client_socket)
}

sub stop {
    my $self = shift;
    delete $self->{_listener}
        if $self->{_listener};
}

1;
