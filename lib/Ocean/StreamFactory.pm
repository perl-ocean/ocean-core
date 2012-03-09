package Ocean::StreamFactory;

use strict;
use warnings;

use Ocean::Stream;
use Ocean::Error;

sub new {
    my ($class, $config) = @_;
    my $self = bless { }, $class;
    return $self;
}

sub create_stream {
    my ($self, $sock, $host, $port) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamFactory::create_stream},
    );
}

1;
