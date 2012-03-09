package Ocean::StreamComponent::SASL::Mechanism::CRAM_MD5;

use strict;
use warnings;

use parent 'Ocean::StreamComponent::SASL::Mechanism';
use Ocean::Error;
use Ocean::Constants::StreamErrorType;
use Ocean::Constants::SASLErrorType;
use Ocean::Util::String qw(gen_random);
use Digest::HMAC_MD5 qw(hmac_md5_hex);
use MIME::Base64;
use Log::Minimal;

sub start {
    my ($self, $auth) = @_;

    $self->{_nonce} = gen_random(10);
    $self->{_delegate}->on_mechanism_delivered_sasl_challenge($self->{_nonce});
}

sub step {
    my ($self, $input) = @_;
    if ($self->{_step} == 0) {
        $self->{_step}++;
        my $decoded = MIME::Base64::decode_base64($input->text);
        chomp $decoded;
        my ($username, $digest) = split /\s/, $decoded;
        unless ($username && $digest) {
            # is NOT_AUTHROIZED better?
            $self->{_delegate}->on_mechanism_failed_auth(
                Ocean::Constants::SASLErrorType::INCORRECT_ENCODING);
            return;
        }
        $self->{_response} = $digest;
        $self->{_username} = $username;
        $self->{_delegate}->on_mechanism_request_sasl_password($username);
    } else {
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

    my $digest = hmac_md5_hex($self->{_nonce}, $password);

    if ($self->{_response} eq $digest) {
        $self->{_delegate}->on_mechanism_completed_auth($self->{_username});
    } else {
        $self->{_delegate}->on_mechanism_failed_auth(
            Ocean::Constants::SASLErrorType::NOT_AUTHORIZED);
    }
}

1;
