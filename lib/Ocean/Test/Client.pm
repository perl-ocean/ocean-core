package Ocean::Test::Client;

use strict;
use warnings;

use AnyEvent::XMPP::Client;

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        _account_config => {
            jid      => $args{jid},
            password => $args{password},
            host     => $args{host},
            port     => $args{port},
        },
        _client => undef,
    }, $class;
    return $self;
}

sub connect {
    my $self = shift;
    $self->{_client} = $self->_create_client();
}

sub _create_client {
    my $self = shift;
    my $client = AnyEvent::XMPP::Client->new();
    $client->add_account( %{ $self->{_account_config} } );
    return $client;
}

sub send_message {
    my ($self, $msg, $dst, $src, $type) = @_;
    $self->{_client}->send_message($msg, $dst, $src, $type);
}

1;
