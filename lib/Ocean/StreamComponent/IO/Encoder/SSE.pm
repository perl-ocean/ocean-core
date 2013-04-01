package Ocean::StreamComponent::IO::Encoder::SSE;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::IO::Encoder::JSON';

use HTTP::Date;
use Log::Minimal;

sub send_http_handshake {
    my ($self, $params) = @_;

    my $header = $self->_build_http_header(
        code    => 200,
        type    => q{OK},
        cookies => $params->{cookies},
        headers => $params->{headers},
    );

    $self->_write($header);
    $self->{_in_stream} = 1;
}

sub _build_http_header {
    my ($self, %params) = @_;

    my @lines = (
        sprintf("HTTP/1.1 %d %s", $params{code}, $params{type}),
        sprintf(q{Date: %s}, HTTP::Date::time2str(time())),
        "Content-Type: text/event-stream",
        "Cache-Control: no-cache, no-store, must-revalidate",
        #"Pragma: no-cache",
        "Connection: keep-alive",
    );

    if ($params{cookies}) {
        while (my ($name, $value) = each %{ $params{cookies} } ) {
            my $cookie = Ocean::Util::HTTPBinding::bake_cookie($name, $value);
            push(@lines, "Set-Cookie: $cookie");
        }
    }

    if ($params{headers}) {
        while (my ($name, $value) = each %{ $params{headers} }) {
            push @lines, sprintf(q{%s: %s}, $name, $value);
        }
    }

    my $header = join("\r\n", @lines);
    $header .= "\r\n\r\n";
    return $header;
}

sub send_packet {
    my ($self, $packet) = @_;
    my $json = $self->_encode_json($packet);
    # escape 'end of data'
    $json =~ s/\n+/\n/g;
    $self->_write("data: $json\n\n");
}

sub send_closing_http_handshake {
    my $self = shift;
    # do nothing
}

1;
