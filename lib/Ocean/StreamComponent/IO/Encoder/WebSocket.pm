package Ocean::StreamComponent::IO::Encoder::WebSocket;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::IO::Encoder::JSON';

use Config;
use Encode;
use Log::Minimal;
use Ocean::Constants::WebSocketOpcode;
use Ocean::Util::WebSocket;
use Ocean::Util::HTTPBinding;

sub send_http_handshake {
    my ($self, $params) = @_;

    my @lines = (
        "HTTP/1.1 101 Switching Protocols",
        "Upgrade: websocket",
        "Connection: Upgrade",
        "Sec-WebSocket-Accept: $params->{accept}",
    );

    if ($params->{protocol}) {
        push(@lines,
            "Sec-WebSocket-Protocol: $params->{protocol}");
    }

    if ($params->{cookies}) {
        while (my ($name, $value) = each %{ $params->{cookies} } ) {
            my $cookie = Ocean::Util::HTTPBinding::bake_cookie($name, $value);
            push(@lines, "Set-Cookie: $cookie");
        }
    }

    if ($params->{headers}) {
        while (my ($name, $value) = each %{ $params->{headers} }) {
            push @lines, sprintf(q{%s: %s}, $name, $value);
        }
    }

    my $header = join("\r\n",
        @lines,
        "",
    );

    $header .= "\r\n";

    debugf("<Stream> <Encoder> send handshake response %s", $header);

    $self->_write($header);
    $self->{_in_stream} = 1;
}

sub send_closing_http_handshake {
    my $self = shift;

    debugf("<Stream> <Encoder> send closing handshake");

    my $packet = $self->build_websocket_frame(
        Ocean::Constants::WebSocketOpcode::CLOSE,
        '');
    $self->_write($packet);
}

sub build_websocket_frame {
    my ($self, $op, $payload) = @_;

    #$payload = Encode::encode('utf8', $payload)
    #    if Encode::is_utf8($payload);

    # this code is borrowed from Mojo::Transaction::WebSocket;

    my $frame = 0;
    vec($frame, 0, 8) = $op | 0b10000000;

    if ($self->{_masked}) {
        debugf("<Stream> <Encoder> masking payload");
        my $mask = pack 'N', int(rand 9999999);
        $payload = $mask . Ocean::Util::WebSocket::xor_mask($payload, $mask);
    }

    my $len = length $payload;
    $len -= 4 if $self->{_masked};

    my $prefix = 0;

    debugf("<Stream> <Encoder> payload length %d", $len);

    if ($len < 126) {
        debugf("<Stream> <Encoder> small payload");
        vec($prefix, 0, 8) = $self->{_masked} ? ($len | 0b10000000) : $len;
        $frame .= $prefix;
    }
    elsif ($len < 65536) {
        debugf("<Stream> <Encoder> extended payload (16bit)");
        vec($prefix, 0, 8) = $self->{_masked} ? (126 | 0b10000000) : 126;
        $frame .= $prefix;
        $frame .= pack 'n', $len;
    }
    else {
        debugf("<Stream> <Encoder> extended payload (64bit)");
        vec($prefix, 0, 8) = $self->{_masked} ? (127 | 0b10000000) : 127;
        $frame .= $prefix;
        $frame .=
          $Config{ivsize} > 4
          ? pack('Q>', $len)
          : pack('NN', $len >> 32, $len & 0xFFFFFFFF);
    }

    debugf("<Stream> <Encoder> head - %s", unpack('B*', $frame));
    debugf("<Stream> <Encoder> opcode - %d", $op);

    $frame .= $payload;
    return $frame;
}

sub build_websocket_text {
    my ($self, $message) = @_;
    my $packet = $self->build_websocket_frame(
        Ocean::Constants::WebSocketOpcode::TEXT_FRAME,
        $message);
    return $packet;
}

sub send_packet {
    my ($self, $data) = @_;
    my $json = $self->_encode_json($data);
    debugf("<Stream> <Encoder> send packet %s", $json);
    my $packet = $self->build_websocket_text($json);
    $self->_write($packet);
}

1;
