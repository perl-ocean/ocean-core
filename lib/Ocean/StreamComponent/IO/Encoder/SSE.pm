package Ocean::StreamComponent::IO::Encoder::SSE;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::IO::Encoder::JSON';

use HTTP::Date;
use Log::Minimal;

sub send_http_handshake {
    my ($self, $params) = @_;
    my @lines = (
        "HTTP/1.1 200 OK", 
        sprintf(q{Date: %s}, HTTP::Date::time2str(time())),
        "Content-Type: text/event-stream",
        "Cache-Control: no-cache, no-store, must-revalidate",
        #"Pragma: no-cache",
        "Connection: keep-alive",
    );
    my $header = join("\r\n", @lines);
    $header .= "\r\n\r\n";
    $self->_write($header);
    $self->{_in_stream} = 1;
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
