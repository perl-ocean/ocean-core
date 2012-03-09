package Ocean::JSON::StanzaParser::Stream;

use strict;
use warnings;

use parent 'Ocean::JSON::StanzaParser';

sub parse {
    my ($self, $obj) = @_;

    return unless exists $obj->{stream};

    my $attr = {};

    $attr->{to}      = $obj->{stream}{to};
    $attr->{id}      = $obj->{stream}{id};
    $attr->{version} = $obj->{stream}{version};

    return $attr;
}

1;
