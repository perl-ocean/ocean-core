package Ocean::Util::String;

use strict;
use warnings;

use base 'Exporter';

our %EXPORT_TAGS = (all => [qw(
    gen_random
    trim
    camelize
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;

sub gen_random {
    my $digit = shift || 10;
    my @salt = ('0'..'9', 'a'..'z', 'A'..'Z');
    my $result = '';
    for (my $i = 0; $i < $digit; $i++) {
        $result .= $salt[int(rand(scalar(@salt)))];
    }
    return $result;
}

sub trim {
    my $str = shift;
    $str =~ s/^\s+//;
    $str =~ s/\s+$//;
    return $str;
}

sub camelize {
    my $str = shift;
    $str = trim($str);
    join('', map { ucfirst lc } split(/\s+/, $str));
}

1;

