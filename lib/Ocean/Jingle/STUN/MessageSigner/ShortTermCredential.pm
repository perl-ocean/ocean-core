package Ocean::Jingle::STUN::MessageSigner::ShortTermCredential;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::MessageSigner';
use Ocean::Jingle::STUN::Util qw(gen_short_term_key);

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _password => $args{password}, 
    }, $class;
    return $self;
}

sub get_key {
    my $self = shift;
    return gen_short_term_key($self->{_password});
}

1;
