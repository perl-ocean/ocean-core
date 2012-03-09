package Ocean::Cluster::Backend::Fetcher::Kestrel;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::Fetcher';

use Ocean::Constants::Cluster;

use AnyEvent;
use AnyEvent::Memcached;
use Log::Minimal;
use Try::Tiny;

sub new {
    my ($class, %args) = @_;

    my $self = bless {
        _queue      => $args{queue},
        _timeout    => $args{timeout}, 
        _timer      => undef,
        _clients    => [],
        _exit_guard => AE::cv,
    }, $class;

    infof("<Fetcher> setup Kestrel::Worker for servers - %s", 
        join(",", @{$args{job_servers}}));

    $self->add_client($_) for @{ $args{job_servers} };

    return $self;
}

sub add_client {
    my ($self, $job_server) = @_;
    my $client = $self->_create_client($job_server);
    push( @{ $self->{_clients} }, $client );
}

sub _create_client {
    my ($self, $job_server) = @_;
    my $client = AnyEvent::Memcached->new(
        servers => $job_server, 
    );
    return $client;
}

sub start {
    my $self = shift;

    infof("<Fetcher> gearman start to work");

    $self->_start_to_fetch($_)  for @{ $self->{_clients} };

    $self->{_exit_guard}->begin();
}

sub _start_to_fetch {
    my ($self, $client) = @_;

    my $command = $self->_create_command();

    $client->get($command, cb => sub {
        my ($value, $err) = @_;             
        $self->_on_fetch($client, $value, $err);
    });
}

sub _on_fetch {
    my ($self, $client, $value, $err) = @_;

    delete $self->{_timer} if $self->{_timer};

    if ($value && !$err) {

        my $callback = $self->{_on_fetch} || sub {};
        $self->on_start($client);

        my $joberr;
        try {
            $callback->($value);
        } catch {
            $joberr = $_;
        };
        $joberr ? $self->on_fail($client, $joberr) 
                : $self->on_complete($client);
    }

    $self->{_timer} = AE::timer 0, 0, sub {
        $self->_start_to_fetch($client);
    };
}

sub _create_command {
    my $self = shift;
    sprintf q{%s/t=%d/close/open}, $self->{_queue}, $self->{_timeout};
}

sub stop {
    my $self = shift;
    # TODO stop each clients
    $self->{_exit_guard}->end();
}

sub on_fail {
    my ($self, $client, $err) = @_;
    infof("<Fetcher> Kestrel: on_fail");
}

sub on_start {
    my ($self, $client) = @_;
    infof("<Fetcher> Kestrel: on_start");
}

sub on_complete {
    my ($self, $client) = @_;
    infof("<Fetcher> Kestrel: on_complete");
}

sub release {
    my $self = shift;
    delete $self->{_timer}
        if $self->{_timer};
}

sub DESTROY {
    my $self = shift;
    $self->release();
}

1;
