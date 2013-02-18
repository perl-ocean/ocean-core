package Ocean::Standalone::Handler::Authen;

use strict;
use warnings;

use parent 'Ocean::Handler::Authen';

use Ocean::Stanza::DeliveryRequestBuilder::HTTPAuthFailure;
use Ocean::Stanza::DeliveryRequestBuilder::HTTPAuthCompletion;
use Ocean::Stanza::DeliveryRequestBuilder::SASLAuthFailure;
use Ocean::Stanza::DeliveryRequestBuilder::SASLAuthCompletion;
use Ocean::Stanza::DeliveryRequestBuilder::SASLPassword;

use Ocean::Util::SASL::PLAIN qw(parse_sasl_plain_b64);
use Ocean::Util::SASL::X_OAUTH2 qw(parse_sasl_x_oauth2_b64);
use Ocean::Util::String qw(gen_random);

use Digest::SHA1 qw(sha1_hex);

sub on_too_many_auth_attempt {
    my ($self, $ctx, $args) = @_;
}

sub on_http_auth_request {
    my ($self, $ctx, $args) = @_;

    my $stream_id = $args->stream_id;
    my $cookie    = $args->cookie;
    my $domain    = $args->domain;
    my $origin    = $args->origin;

    if (!$cookie) {
        $self->log_debug("on_http_auth cookie not found");
        my $builder = Ocean::Stanza::DeliveryRequestBuilder::HTTPAuthFailure->new;
        $builder->stream_id($stream_id);
        $ctx->deliver($builder->build());
        return;
    }
    my $cookie_value = $cookie->{foo} || '';
    $self->log_debug("on_http_auth found cookie %s", $cookie_value);
    my $user = $ctx->get('db')->find_user_by_cookie($cookie_value);
    if (!$user) {
        $self->log_debug("on_http_auth user not found");
        my $builder = Ocean::Stanza::DeliveryRequestBuilder::HTTPAuthFailure->new;
        $builder->stream_id($stream_id);
        $ctx->deliver($builder->build());
        return;
    }

    $self->log_debug("on_http_auth found user %s for cookie", $user->username);
    my $session_id = sha1_hex($cookie_value);

    my $builder = Ocean::Stanza::DeliveryRequestBuilder::HTTPAuthCompletion->new;

    $builder->stream_id($stream_id);
    $builder->session_id($session_id);
    $builder->user_id($user->user_id);
    $builder->username($user->username);
    $builder->add_cookie(foo => $cookie_value);
    $builder->add_cookie(bar => { value => 'fugafuga', domain => $domain, path => '/foo' });
    $ctx->deliver($builder->build());
}


sub on_sasl_auth_request {
    my ($self, $ctx, $args) = @_;

    if ($args->mechanism eq 'PLAIN') {
        _on_sasl_auth_request_plain(@_);
        return;
    } elsif ($args->mechanism eq 'X-OAUTH2') {
        _on_sasl_auth_request_oauth2(@_);
        return;
    } else {
        my $stream_id = $args->stream_id;
        my $builder = 
            Ocean::Stanza::DeliveryRequestBuilder::SASLAuthFailure->new;
        $builder->stream_id($stream_id);
        $ctx->deliver($builder->build());
        return;
    }
}

sub _on_sasl_auth_request_plain {
    my ($self, $ctx, $args) = @_;

    my $stream_id = $args->stream_id;

    $self->log_info("PLAIN sasl authentication");
    $self->log_info("Received %s", $args->text||'');

    my ($authcid, $password) = 
        parse_sasl_plain_b64($args->text||'');

    $self->log_info("Username - %s", $authcid);
    $self->log_info("Password - %s", $password);

    unless ($authcid && $password) {
        $self->log_info("both username and password needed");
        my $builder = 
            Ocean::Stanza::DeliveryRequestBuilder::SASLAuthFailure->new;
        $builder->stream_id($stream_id);
        $ctx->deliver($builder->build());
        return;
    }

    my $user = $ctx->get('db')->find_user_by_username($authcid);
    unless ($user) {
        $self->log_info("User %s doesn't exist", $authcid);
        my $builder = 
            Ocean::Stanza::DeliveryRequestBuilder::SASLAuthFailure->new;
        $builder->stream_id($stream_id);
        $ctx->deliver($builder->build());
        return;
    }

    if ($user->password eq $password) {
        $self->log_info("Password matched");
        my $builder = 
            Ocean::Stanza::DeliveryRequestBuilder::SASLAuthCompletion->new;
        $builder->stream_id($stream_id);
        $builder->user_id($user->user_id);
        $builder->username($user->username);
        $builder->session_id( sha1_hex( gen_random(32) ) );
        $ctx->deliver($builder->build());
    } else {
        $self->log_info("Password not matched");
        my $builder = 
            Ocean::Stanza::DeliveryRequestBuilder::SASLAuthFailure->new;
        $builder->stream_id($stream_id);
        $ctx->deliver($builder->build());
    }
}

sub _on_sasl_auth_request_oauth2 {
    my ($self, $ctx, $args) = @_;

    my $stream_id = $args->stream_id;

    $self->log_info("X-OAUTH2 sasl authentication");
    $self->log_info("Received %s", $args->text||'');

    my $authcid = undef;
    my $token = undef;

    ($authcid, $token) =
        parse_sasl_x_oauth2_b64($args->text||'');

    $self->log_info("Username - %s", $authcid);
    $self->log_info("Token    - %s", $token);

    unless ($authcid && $token) {
        $self->log_info("both username and token needed");
        my $builder =
            Ocean::Stanza::DeliveryRequestBuilder::SASLAuthFailure->new;
        $builder->stream_id($stream_id);
        $ctx->deliver($builder->build());
        return;
    }

    my $user = $ctx->get('db')->find_user_by_username($authcid);
    unless ($user) {
        $self->log_info("User %s doesn't exist", $authcid);
        my $builder =
            Ocean::Stanza::DeliveryRequestBuilder::SASLAuthFailure->new;
        $builder->stream_id($stream_id);
        $ctx->deliver($builder->build());
        return;
    }

    if ($user->oauth_token eq $token) {
        $self->log_info("Token auth success");
        my $builder =
            Ocean::Stanza::DeliveryRequestBuilder::SASLAuthCompletion->new;
        $builder->stream_id($stream_id);
        $builder->user_id($user->user_id);
        $builder->username($user->username);
        $builder->session_id( sha1_hex( gen_random(32) ) );
        $ctx->deliver($builder->build());
    } else {
        $self->log_info("Token auth fail");
        my $builder =
            Ocean::Stanza::DeliveryRequestBuilder::SASLAuthFailure->new;
        $builder->stream_id($stream_id);
        $ctx->deliver($builder->build());
    }
}

sub on_sasl_password_request {
    my ($self, $ctx, $args) = @_;

    my $stream_id = $args->stream_id;
    my $username  = $args->username;

    my $user = $ctx->get('db')->find_user_by_username($username);
    unless ($user) {
        $self->log_info("User %s doesn't exist", $username);
        my $builder = 
            Ocean::Stanza::DeliveryRequestBuilder::SASLAuthFailure->new;
        $builder->stream_id($stream_id);
        $ctx->deliver($builder->build());
        return;
    }
    my $builder = Ocean::Stanza::DeliveryRequestBuilder::SASLPassword->new;
    $builder->stream_id($stream_id);
    $builder->password($user->password);
    $ctx->deliver($builder->build());
}

sub on_sasl_success_notification {
    my ($self, $ctx, $args) = @_;

    my $stream_id = $args->stream_id;
    my $username  = $args->username;

    my $user = $ctx->get('db')->find_user_by_username($username);
    unless ($user) {
        $self->log_info("User %s doesn't exist", $username);
        my $builder = 
            Ocean::Stanza::DeliveryRequestBuilder::SASLAuthFailure->new;
        $builder->stream_id($stream_id);
        $ctx->deliver($builder->build());
        return;
    }

    my $builder = 
        Ocean::Stanza::DeliveryRequestBuilder::SASLAuthCompletion->new;
    $builder->stream_id($stream_id);
    $builder->user_id($user->user_id);
    $builder->username($user->username);
    $builder->session_id( sha1_hex( gen_random(32) ) );
    $ctx->deliver($builder->build());
}

1;
