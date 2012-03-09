package Ocean::StreamComponent::SASL::Mechanism;

use strict;
use warnings;

use Ocean::Error;

sub new {
    my $class = shift;
    my $self = bless {
        _step     => 0,
        _delegate => undef,
    }, $class;
    return $self;
}

sub set_delegate {
    my ($self, $delegate) = @_;
    $self->{_delegate} = $delegate;
}

sub release {
    my $self = shift;
    delete $self->{_delegate}
        if $self->{_delegate};
}

sub start {
    my ($self, $auth) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamComponent::SASL::Mechanism::start}, 
    );
}

sub step {
    my ($self, $input) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamComponent::SASL::Mechanism::step}, 
    );
}

sub on_protocol_delivered_sasl_password {
    my ($self, $password) = @_;
    Ocean::Error::AbstractMethod->throw(
        message => q{Ocean::StreamComponent::SASL::Mechanism::on_protocol_delivered_sasl_password}, 
    );
}

1;
