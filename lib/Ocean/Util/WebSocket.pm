package Ocean::Util::WebSocket;

use strict;
use warnings;

use base 'Exporter';

our %EXPORT_TAGS = (all => [qw(
    xor_mask
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

sub xor_mask {
  my ($input, $mask) = @_;
    # This code is borrowed from
    # Mojo::Transaction::WebSocket
    $mask = $mask x 128;
    my $output = '';
    $output .= $_ ^ $mask while length($_ = substr($input, 0, 512, '')) == 512;
    $output .= $_ ^ substr($mask, 0, length, '');
    return $output;
}

1;
