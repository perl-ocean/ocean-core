package Ocean::Cluster::Backend::Fetcher::RabbitMQ;

use strict;
use warnings;

use parent 'Ocean::Cluster::Backend::Fetcher';

use Ocean::Constants::Cluster;

use AnyEvent;
use AnyEvent::RabbitMQ;
use Log::Minimal;
use Try::Tiny;

sub new {
    my ($class, %args) = @_;

    my $self = bless {
        _host       => $args{host},
        _port       => $args{port},
        _user       => $args{user},
        _pass       => $args{pass},
        _vhost      => $args{vhost},
        _is_closing => 0,
        _queue      => $args{queue},
        _timeout    => $args{timeout}, 
        _timer      => undef,
        _exit_guard => AE::cv,
    }, $class;

    $self->{_client} = $self->_create_client($args{job_servers});

    return $self;
}

sub _create_client {
    my ($self, $servers) = @_;
    return AnyEvent::RabbitMQ->new->load_xml_spec;
}

sub start {
    my $self = shift;

    infof("<Fetcher> start to work");

    $self->{_client}->connect(
        host       => $self->{_host},
        port       => $self->{_port}, 
        user       => $self->{_user}, 
        pass       => $self->{_pass}, 
        vhost      => $self->{_vhost}, 
        timeout    => 0, 
        on_success => sub { $self->on_connection_built(@_)   },
        on_failure => sub { $self->on_connection_failure(@_) },
        on_close   => sub { $self->on_connection_closed(@_)  },
    );

    $self->{_exit_guard}->begin();
}

sub stop {
    my $self = shift;
    return if $self->{_is_closing};
    $self->{_is_closing} = 1;
    $self->{_client}->close();
    $self->{_exit_guard}->end();
}

sub on_connection_built {
    my $self = shift;

    infof("<Fetcher> established connection");
    infof("<Fetcher> try to open channel");

    $self->{_client}->open_channel(
        on_success => sub { $self->on_channel_opened(@_)          },
        on_failure => sub { $self->on_channel_opening_failure(@_) },
        on_close   => sub { $self->on_channel_closed(@_)          },
    );

}

sub on_connection_failure {
    my ($self, $message) = @_;

    infof("<Fetcher> failed to establish connection, '%s'", $message);

    # TODO reconnect to another server?
    $self->stop();
}

sub on_connection_closed {
    my ($self, $frame) = @_;

    infof("<Fetcher> closed connection to rabbitmq server");

    my $method_frame = $frame->method_frame;
    infof("<Fetcher> %d: %s", 
        $method_frame->reply_code, 
        $method_frame->reply_text);
}

sub on_channel_opened {
    my ($self, $channel) = @_;

    $channel->declare_queue(
        queue => $self->{_queue}, 
    );

    for my $queue ( $self->{_queues} ) {
        $channel->consume(
            queue        => $queue,
            consumer_tag => $self->{_consumer_tag},
            on_consume   => sub { $self->on_channel_consume(@_)           }, 
            on_success   => sub { $self->on_channel_consuming_success(@_) },
            on_failure   => sub { $self->on_channel_consuming_failure(@_) },
        );
    }

    # $channel->declare_exchange(
    #     exchange    => '', 
    #     type        => '',
    #     passive     => 0,
    #     durable     => 0,
    #     auto_delete => 0,
    #     internal    => 0,
    #     on_success  => sub {},
    #     on_failure  => sub {},
    # );
}

sub on_channel_opening_failure {
    my ($self, $message) = @_;

    critf("<Fetcher> failed to open channel, %s", $message);

    # TODO reconnect to another server?
    $self->stop();
}

sub on_channel_closed {
    my ($self, $frame) = @_;

    infof("<Fetcher> channel closed");

    my $method_frame = $frame->method_frame;
    infof("<Fetcher> %d: %s", 
        $method_frame->reply_code, 
        $method_frame->reply_text);

    # TODO reconnect to another server?
    $self->stop();
}

sub on_channel_consume {
    my ($self, $packet) = @_;

    $self->{_on_fetch}->($packet->{body}->payload());
}

sub on_channel_consuming_success {
    my ($self, $frame) = @_;

    infof("<Fetcher> successfully consumed");

    my $method_frame = $frame->method_frame;
    infof("<Fetcher> %d: %s", 
        $method_frame->reply_code, 
        $method_frame->reply_text);
}

sub on_channel_consuming_failure {
    my ($self, $message) = @_;

    critf("<Fetcher> failed to consume, %s", $message);

    # TODO reconnect to another server?
    $self->stop();
}

1;
