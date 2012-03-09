package Ocean::Test::Cluster::Bridge;

use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _frontends         => {},
        _backend_fetcher   => $args{backend_fetcher}, 
        _backend_deliverer => $args{backend_deliverer}, 
    }, $class;

    $self->{_backend_deliverer}->on_deliver(sub {
        my ($host, $data) = @_;        
        my $frontend = $self->{_frontends}{$host};
        return unless $frontend;
        $frontend->{fetcher}->emulate_raw_job($data);
    });

    return $self;
}

sub register_frontend {
    my ($self, %args) = @_;

    my $fetcher    = $args{fetcher};
    my $dispatcher = $args{dispatcher};
    my $host       = $args{host};

    $dispatcher->on_dispatch(sub {
        my ($data) = @_;
        $self->{_backend_fetcher}->emulate_raw_job($data);
    });

    $self->{_frontends}{$host} = {
        fetcher    => $fetcher, 
        dispatcher => $dispatcher,
    };
}

1;
