package Ocean::StreamComponent::SASL::Mechanism::DIGEST_MD5;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::SASL::Mechanism';
use Ocean::Error;
use Ocean::Constants::StreamErrorType;
use Ocean::Constants::SASLErrorType;
use Ocean::Util::String qw(gen_random trim);
use Digest::MD5 qw(md5 md5_hex);
use MIME::Base64;
use Log::Minimal;

sub start {
    my ($self, $auth) = @_;

    $self->{_nonce} = gen_random(10);

    my $challenge = sprintf 
        q{nonce="%s",qop="auth",charset=utf-8,algorithm=md5-sess}, 
        $self->{_nonce};

    $self->{_delegate}->on_mechanism_delivered_sasl_challenge($challenge);
}

sub step {
    my ($self, $input) = @_;

    if ($self->{_step} == 0) {
        $self->{_step}++;

        my $decoded = MIME::Base64::decode_base64($input->text);
        chomp $decoded;
        my $input_params = $self->_parse_client_input($decoded);
        unless ($input_params) {
            # is NOT_AUTHROIZED better?
            $self->{_delegate}->on_mechanism_failed_auth(
                Ocean::Constants::SASLErrorType::INCORRECT_ENCODING);
            return;
        }

        my $response = delete $input_params->{response};
        my $username = $input_params->{username};
        unless ($response) {
            # is NOT_AUTHROIZED better?
            $self->{_delegate}->on_mechanism_failed_auth(
                Ocean::Constants::SASLErrorType::INCORRECT_ENCODING);
            return;
        }

        $self->{_username}     = $username;
        $self->{_response}     = $response;
        $self->{_input_params} = $input_params;

        $self->{_delegate}->on_mechanism_request_sasl_password($username);
        return;
    }
    elsif ($self->{_step} == 2) {
        $self->{_step}++;
        $self->{_delegate}->on_mechanism_completed_auth($self->{_username});
        return;
    }
    else {
        Ocean::Error::ProtocolError->throw(
            type => Ocean::Constants::StreamErrorType::POLICY_VIOLATION, 
        );
    }
}


sub on_protocol_delivered_sasl_password {
    my ($self, $password) = @_;

    Ocean::Error::ConditionMismatchedServerEvent->throw
        unless $self->{_step} == 1;

    $self->{_step}++;

    my $digest = $self->_gen_response_digest(
        password => $password,
        nonce    => $self->{_nonce},
        prefix   => q{AUTHENTICATE},
        params   => $self->{_input_params},
    );

    unless ($self->{_response} eq $digest) {
        $self->{_delegate}->on_mechanism_failed_auth(
            Ocean::Constants::SASLErrorType::NOT_AUTHORIZED);
        return;
    }

    my $response = $self->_gen_response_digest(
        password => $password,
        nonce    => $self->{_nonce},
        params   => $self->{_input_params},
    );

    my $challenge = sprintf(q{rspauth=%s}, $response);
    $self->{_delegate}->on_mechanism_delivered_sasl_challenge($challenge);
}

sub _parse_client_input {
    my ($self, $text) = @_; 
    $text =~ s/(?:\r|\n)//g;
    my $params = {};
    for my $pairs ( split /,/, $text ) {
        my $idx = index($pairs, '=');
        return unless ($idx >= 0);
        my $key   = substr($pairs, 0, $idx);
        my $value = trim(substr($pairs, $idx + 1));
        $value =~ s/^\"(.*)\"$/$1/;
        $params->{$key} = $value;
    }
    $params;
}

sub _gen_response_digest {
    my ($self, %args) = @_;

    my $params     = $args{params};
    my $password   = $args{password}         || '';
    my $nonce      = $args{nonce}            || '';
    my $prefix     = $args{prefix}           || '';
    my $user       = $params->{username}     || '';
    my $authzid    = $params->{authzid}      || undef;
    my $realm      = $params->{realm}        || '';
    my $cnonce     = $params->{cnonce}       || '';
    my $digest_uri = $params->{'digest-uri'} || '';
    my $nc         = $params->{nc}           || '';
    my $qop        = $params->{qop}          || '';

    my $A1 = join(":",
        md5(join(":", $user, $realm, $password)),
        defined($authzid) ? ($nonce, $cnonce, $authzid) : ($nonce, $cnonce));

    my $A2 = join(":", $qop eq 'auth'
        ? ($prefix, $digest_uri)
        : ($prefix, $digest_uri, "00000000000000000000000000000000")
    ); 

    my $response = md5_hex(
        join(":",
            md5_hex($A1),
            $nonce,
            $nc,
            $cnonce,
            $qop,
            md5_hex($A2),
        )
    );
    $response;
}

1;
