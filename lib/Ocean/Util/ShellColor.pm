package Ocean::Util::ShellColor;

use strict;
use warnings;

use base 'Exporter';

our %EXPORT_TAGS = (all => [qw(
    paint_text
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

use constant BLACK   => 30;
use constant RED     => 31;
use constant GREEN   => 32;
use constant YELLOW  => 33;
use constant BLUE    => 34;
use constant MAGENTA => 35;
use constant CYAN    => 36;
use constant WHITE   => 37;

sub paint_text {
    my ($message, $color) = @_;
    $message = "\e[" . $color . "m". $message. "\e[m" if $color;
    return $message;
}

1;
