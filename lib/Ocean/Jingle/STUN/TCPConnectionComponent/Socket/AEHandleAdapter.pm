package Ocean::Jingle::STUN::TCPConnectionComponent::Socket::AEHandleAdapter;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::TCPConnectionComponent::Socket';

use Ocean::Util::AnyEvent qw(refresh_write_buffer_memory);
use Socket ();
use Log::Minimal;
use Try::Tiny;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _handle => $args{handle},
    }, $class;
    $self->_initialize_handle($args{handle});
    return $self;
}

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
        CORE::shutdown($self->{_handle}->fh, 1);
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
    $handle->timeout($self->{_timeout});
    $handle->on_timeout(sub {
       $self->{_delegate}->on_socket_timeout(); 
    });
    $handle->on_read(sub {
        my $data = $handle->rbuf;
        $handle->rbuf = '';
        debugf('<Connection> <Socket> @packet_in ' . $data);
        #$data = Encode::decode_utf8($data);
        $self->{_delegate}->on_socket_read_data(\$data);     
    });
    $handle->on_starttls(sub {
        my ($h, $success, $message) = @_;
        if ($success) {
            debugf("<Connection> <Socket> tls negotiation success");
        } else {
            debugf("<Connection> <Socket> tls negotiation failed");
            $self->{_delegate}->close();     
        }
    });
    $handle->on_drain(sub {
        refresh_write_buffer_memory($handle);
    });
    $handle->on_error(sub {
        try {
            debugf('<Connection> <Socket> @error');
            $self->{_delegate}->on_socket_eof();     
        } catch {
            critf("<Connection> <Socket> caught exception on eof: $_");
        };
    });
    $handle->on_eof(sub {
        try {
            debugf('<Connection> <Socket> @eof');
            $self->{_delegate}->on_socket_eof();
        } catch {
            critf("<Connection> <Socket> caught exception on eof: $_");
        };
    });
}

sub close {
    my $self = shift;
    debugf('<Connection> <Socket> @shutdown');
    $self->shutdown();
    $self->{_delegate}->on_socket_closed();
}

sub push_write {
    my ($self, $data) = @_;
    debugf('<Connection> <Socket> @packet_out ' . $data);
    $self->{_handle}->push_write($data);
}

1;
