package Ocean::StreamComponent::IO::Socket::AEHandleAdapter;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::IO::Socket';

use Ocean::Config;
use Ocean::Util::Config qw(value_is_true);
use Ocean::Util::AnyEvent qw(refresh_write_buffer_memory);
use Socket ();
use Log::Minimal;
use Try::Tiny;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _handle  => $args{handle},
        _host    => $args{host},
        _port    => $args{port},
    }, $class;
    $self->_initialize_handle($args{handle});
    return $self;
}

sub host { $_[0]->{_host} }
sub port { $_[0]->{_port} }

sub set_delegate {
    my ($self, $delegate) = @_;
    $self->{_delegate} = $delegate;
}

# call this before release parent object
# to avoid cyclic-reference
# and to shutdown the raw-connection.
sub release {
    my $self = shift;
    $self->shutdown();
    $self->_release_delegate();
}

sub shutdown {
    my $self = shift;
    if ($self->{_handle}) {
        $self->{_handle}->push_shutdown();
        $self->{_handle}->destroy();
        delete $self->{_handle};
    }
}

sub _release_delegate {
    my $self = shift;
    delete $self->{_delegate} 
        if $self->{_delegate};
}

sub _initialize_handle {
    my ($self, $handle) = @_;
    $handle->on_timeout(sub {
       $self->{_delegate}->on_socket_timeout(); 
    });
    $handle->on_read(sub {
        my $data = $handle->rbuf;
        $handle->rbuf = '';
        infof('<Stream> <Socket> @packet_in ' . $data)
            if value_is_true( Ocean::Config->instance->get(log => q{show_packets}) );
        #$data = Encode::decode_utf8($data);
        $self->{_delegate}->on_socket_read_data(\$data);     
    });
    $handle->on_starttls(sub {
        my ($h, $success, $message) = @_;
        if ($success) {
            debugf("<Stream> <Socket> tls negotiation success");
            $self->{_delegate}->on_socket_negotiated_tls();
        } else {
            debugf("<Stream> <Socket> tls negotiation failed");
            $self->{_delegate}->close();     
        }
    });
    $handle->on_drain(sub {
        refresh_write_buffer_memory($handle);
    });
    $handle->on_error(sub {
        try {
            debugf('<Stream> <Socket> @error');
            $self->{_delegate}->on_socket_eof();     
        } catch {
            critf("<Stream> <Socket> caught exception on eof: $_");
        };
    });
    $handle->on_eof(sub {
        try {
            debugf('<Stream> <Socket> @eof');
            $self->{_delegate}->on_socket_eof();
        } catch {
            critf("<Stream> <Socket> caught exception on eof: $_");
        };
    });
}

sub close {
    my $self = shift;
    debugf('<Stream> <Socket> @shutdown');
    $self->shutdown();
    $self->{_delegate}->on_socket_closed();
}

sub accept_tls {
    my ($self, $tls_conf) = @_;
    debugf('<Stream> <Socket> @start_tls');
    $self->{_handle}->starttls(accept => $tls_conf);
}

sub push_write {
    my ($self, $data) = @_;
    infof('<Stream> <Socket> @packet_out ' . $data)
            if value_is_true( Ocean::Config->instance->get(log => q{show_packets}) );
    $self->{_handle}->push_write($data);
}

1;
