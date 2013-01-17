package Ocean::StreamComponent::IO::Decoder::JSON::Base;

use strict;
use warnings;

use HTTP::Parser::XS qw(parse_http_request);
use Log::Minimal;
use List::MoreUtils qw(any);

use Ocean::Constants::StreamErrorType;
use Ocean::Error;
use Ocean::Util::HTTPBinding;

use constant {
    STATE_INIT        => 0,
    STATE_HANDSHAKED  => 1,
};

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _buffer          => '', 
        _state           => STATE_INIT,
        _on_handshake    => sub {},
        _on_read_frame   => sub {},
#        _max_buffer_size => $args{max_buffer_size} || 1024 * 10,
    }, $class;
    return $self;
}

sub on_handshake {
    my ($self, $callback) = @_;
    $self->{_on_handshake} = $callback;
}

sub on_read_frame {
    my ($self, $callback) = @_;
    $self->{_on_read_frame} = $callback;
}

sub reset {
    my $self = shift;
    $self->{_state}  = STATE_INIT;
    $self->{_buffer} = '';
}

sub release {
    my $self = shift;
    delete $self->{_on_handshake}
        if $self->{_on_handshake};
    delete $self->{_on_read_frame}
        if $self->{_on_read_frame};
}

sub parse_more {
    my ($self, $data) = @_;
    $self->{_buffer} .= $data;
    $self->_parse();
    # TODO
    #if (length $self->{buffer} > $self->{_max_buffer_size}) {
    #    Ocean::Error::ProtocolError->throw();
    #}
}

sub _parse {
    my $self = shift;
    if ($self->{_state} == STATE_INIT) {
        my $pos = index($self->{_buffer}, "\r\n\r\n");
        if ($pos >= 0) {
            my $header = substr($self->{_buffer}, 0, $pos + 4);
            $self->{_buffer} = '';

            my $env = {};
            my $ret = parse_http_request($header, $env);
            unless ($ret > 0) {
                $self->reset();
                debugf("<Stream> <Decoder> Failed to parse header: '%s'", $header);

                Ocean::Error::HTTPHandshakeError->throw(
                    code => 400,
                    type => q{Bad Request}, 
                );
                return;
            }

            debugf("<Stream> <Decoder> parsed header successfully");

            if ( $env->{REQUEST_METHOD} ne 'GET') {
                $self->reset();
                debugf("<Stream> <Decoder> invalid request method: '%s'", $header);
                Ocean::Error::HTTPHandshakeError->throw(
                    code => 400,
                    type => q{Bad Request}, 
                );
                return;
            }

            my %header_params = ();

            # check/get host
            $header_params{host} = Ocean::Util::HTTPBinding::check_host($self, $env->{HTTP_HOST});

            # get cookie
            if ( exists $env->{HTTP_COOKIE} ) {
                debugf("<Stream> <Decoder> found cookie: %s", $env->{HTTP_COOKIE});
                my $cookie = Ocean::Util::HTTPBinding::parse_cookie($env->{HTTP_COOKIE});
                $header_params{cookie} = $cookie;
            }

            # TODO check other request header

            # TODO check server sent event parameters
            # check 'Accept' includes 'text/event-stream'

            $self->{_on_handshake}->(\%header_params);
            $self->{_state} = STATE_HANDSHAKED;
        } else {
            # Ignore 
            # XXX or throw exception?
            # Ocean::Error::ProtocolError->throw();
            $self->{_buffer} = '';
        }
    }
}

1;
