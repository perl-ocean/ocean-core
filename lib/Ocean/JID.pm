package Ocean::JID;

use strict;
use warnings;

use Log::Minimal; # TODO remove
# most of this code is borrowed from DJabberd::JID

use overload
    '""' => \&as_string;

use constant {
    NODE       => 0,
    DOMAIN     => 1,
    RES        => 2,
    AS_STRING  => 3,
    AS_BSTRING => 4,
};

sub new {
    return undef unless $_[1] && $_[1] =~
        m!^(?: ([\x29\x23-\x25\x28-\x2E\x30-\x39\x3B\x3D\x3F\x41-\x7E]{1,1023}) \@)? # $1: optional node
           ([a-zA-Z0-9\.\-]{1,1023})                                                 # $2: domain
           (?: /(.{1,1023})   )?                                           # $3: optional resource
           $!x;

    # XXX invalid host jid
    # return undef if (!$1 && $3);

    return bless [ $1, $2, $3 ], $_[0];
}

sub build {
    my ($class, $username, $domain, $resource) = @_;
    debugf('<JID> build %s, %s, %s', $username || 'undef', $domain || 'undef', $resource || 'undef');
    die 'bad JID' unless ( $username && $username ne '' && $domain && $domain ne '' ); # TODO remove
    my $jid = join('@', $username, $domain);
    $jid = join('/', $jid, $resource) if ($resource);
    return Ocean::JID->new($jid);
}

sub is_bare {
    return 0 unless $_[0]->[NODE];
    return $_[0]->[RES] ? 0 : 1;
}

sub is_host {
    return $_[0]->[NODE] ? 0 : 1;
}

sub node {
    return $_[0]->[NODE];
}

sub domain {
    return $_[0]->[DOMAIN];
}

sub resource {
    return $_[0]->[RES];
}

sub belongs_to {
    my ($self, $parent_domain) = @_;
    my $child_domain = $self->domain;
    return ($child_domain =~ /(?:(.+)\.)?$parent_domain/) ? 1 : 0;
}

sub eq {
    my ($self, $jid) = @_;
    return $jid && $self->as_string eq $jid->as_string;
}

sub as_string {
    my $self = $_[0];
    return $self->[AS_STRING] ||=
        join('',
             ($self->[NODE] ? ($self->[NODE], '@') : ()),
             $self->[DOMAIN],
             ($self->[RES] ? ('/', $self->[RES]) : ()));
}

sub as_bare_string {
    my $self = $_[0];
    return $self->[AS_BSTRING] ||=
        join('',
             ($self->[NODE] ? ($self->[NODE], '@') : ()),
             $self->[DOMAIN]);
}

1;
