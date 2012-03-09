package Ocean::LogFormatter::Color;

use strict;
use warnings;

use parent 'Ocean::LogFormatter';

use Ocean::Util::ShellColor qw(paint_text);

my %COLOR_MAP = (
    'DEBUG'    => Ocean::Util::ShellColor::WHITE,
    'INFO'     => Ocean::Util::ShellColor::CYAN,
    'WARN'     => Ocean::Util::ShellColor::YELLOW,
    'CRITICAL' => Ocean::Util::ShellColor::RED,
);

sub format {
    my ($self, $time, $type, $message, $trace) = @_;

    my $color = $COLOR_MAP{ $type } 
        or die sprintf "Unknown log level: '%s'", $type;

    return "$time ". paint_text("[$type] $message", $color) . "\n";
}

1;
