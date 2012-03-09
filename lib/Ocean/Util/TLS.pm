package Ocean::Util::TLS;

use strict;
use warnings;

use base 'Exporter';

use Ocean::Config;

our %EXPORT_TAGS = (all => [qw(
    require_starttls
    require_initialtls
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

sub require_starttls {
    return Ocean::Config->instance->has_section('tls') 
        && _is_pure_xmpp();
}

sub require_initialtls {
    return Ocean::Config->instance->has_section('tls') 
        && !_is_pure_xmpp();
}

sub _is_pure_xmpp {
    my $type = Ocean::Config->instance->get(server => 'type');
    return ($type && $type eq 'xmpp');
}

1;
