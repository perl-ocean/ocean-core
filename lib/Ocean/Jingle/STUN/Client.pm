package Ocean::Jingle::STUN::Client;

use strict;
use warnings;

use constant DEFAULT_RTO      =>  500;
use constant DEFAULT_PORT     => 3478;
use constant DEFAULT_RC       =>    7;
use constant DEFAULT_SOFTWARE => 'Ocean STUN Client';

our $VERSION = '1.0.0';

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _host                  => $args{host},
        _port                  => $args{port}     || DEFAULT_PORT,
        _base_RTO              => $args{RTO}      || DEFAULT_RTO, 
        _Rc                    => $args{Rc}       || DEFAULT_RC, 
        _software              => $args{software} || join('/', DEFAULT_SOFTWARE, $VERSION),
        _attribute_codec_store => $args{attribute_codec_store},
        _current_RTO           => undef,
        _current_Rc            => undef,
        _RTO_timer             => undef,
    }, $class;
    return $self;
}

sub send_binding_request {
    my $self = shift;
}

1;
