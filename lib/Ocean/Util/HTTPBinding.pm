package Ocean::Util::HTTPBinding;

use strict;
use warnings;

use base 'Exporter';

use URI::Escape ();
use Log::Minimal;
use List::MoreUtils qw(any);

use Ocean::Error;
use Ocean::Config;

our %EXPORT_TAGS = (all => [qw(
    bake_cookie
    parse_cookie
    parse_host
    check_host
)]);

our @EXPORT_OK = map { @$_ } values %EXPORT_TAGS;


# these code is borrowed from Plack::Request and Plack::Response

my @MON  = qw( Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec );
my @WDAY = qw( Sun Mon Tue Wed Thu Fri Sat );

sub _date {
    my($expires) = @_;

    if ($expires =~ /^\d+$/) {
        # all numbers -> epoch date
        # (cookies use '-' as date separator, HTTP uses ' ')
        my($sec, $min, $hour, $mday, $mon, $year, $wday) = gmtime($expires);
        $year += 1900;

        return sprintf("%s, %02d-%s-%04d %02d:%02d:%02d GMT",
                       $WDAY[$wday], $mday, $MON[$mon], $year, $hour, $min, $sec);

    }

    return $expires;
}


sub bake_cookie {
    my($name, $val) = @_;

    return '' unless defined $val;
    $val = { value => $val } unless ref $val eq 'HASH';

    my @cookie = ( URI::Escape::uri_escape($name) . "=" . URI::Escape::uri_escape($val->{value}) );
    push @cookie, "domain=" . $val->{domain}   if $val->{domain};
    push @cookie, "path=" . $val->{path}       if $val->{path};
    push @cookie, "expires=" . _date($val->{expires}) if $val->{expires};
    push @cookie, "secure"                     if $val->{secure};
    push @cookie, "HttpOnly"                   if $val->{httponly};

    return join "; ", @cookie;
}

sub parse_cookie {
    my $str = shift;

    my %results;
    my @pairs = grep /=/, split "[;,] ?", $str;
    for my $pair ( @pairs ) {
        # trim leading trailing whitespace
        $pair =~ s/^\s+//; $pair =~ s/\s+$//;

        my ($key, $value) = map URI::Escape::uri_unescape($_), split( "=", $pair, 2 );

        # FIXME
        if ($value =~ /^\"(.*)\"$/) {
            $value = $1;
        }

        # FIXME
        if ($value =~ /^\'(.*)\'$/) {
            $value = $1;
        }

        # Take the first one like CGI.pm or rack do
        $results{$key} = $value unless exists $results{$key};
    }

    return \%results;
}

sub parse_host {
    my $str = shift;
    return unless $str;
    my ($host, $port) = split /:/, $str;
    return $host;
}

sub check_host {
    my ($decoder, $env_host) = @_;

    my $domains = Ocean::Config->instance->get(server => q{domain});
    my $host = parse_host($env_host);

    unless (defined $host && (any { $host eq $_ } @$domains) ) {
        $decoder->reset() if $decoder;
        debugf("<Stream> <Decoder> invalid domain: '%s'", $host);
        Ocean::Error::HTTPHandshakeError->throw(
            code => 400,
            type => q{Bad Request},
        );
        return;
    }

    return $host;
}

1;
