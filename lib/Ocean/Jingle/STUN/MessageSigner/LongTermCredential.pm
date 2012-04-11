package Ocean::Jingle::STUN::MessageSigner::LongTermCredential;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::MessageSigner';
use Ocean::Jingle::STUN::Util qw(gen_long_term_key);

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _password => $args{password}, 
        _realm    => $args{realm}, 
        _username => $args{username}, 
    }, $class;
    return $self;
}

sub get_key {
    my $self = shift;
    return gen_long_term_key(
        $self->{_username},
        $self->{_realm},
        $self->{_password});
}

1;
