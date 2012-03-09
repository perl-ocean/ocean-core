package Ocean::Stanza::DeliveryRequest::DiscoInfo;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';
use Ocean::Util::JID qw(to_jid);
use Ocean::Stanza::DeliveryRequest::DiscoInfoIdentity;

__PACKAGE__->mk_accessors(qw(
    id
    from
    to
    identities
    features
));

sub new {
    my ($class, $args) = @_;

    my $identities = delete $args->{identities} || [];
    my $features   = delete $args->{features}   || [];

    my $self = $class->SUPER::new($args);

    $self->{to} = to_jid($self->{to}) if $self->{to};

    $self->{identities} = [];
    $self->{features}   = [];

    for my $identity_args ( @$identities ) {
        push( @{ $self->{identities} }, 
            Ocean::Stanza::DeliveryRequest::DiscoInfoIdentity->new($identity_args));
    }

    for my $feature_args ( @$features ) {
        push( @{ $self->{features} }, 
            #Ocean::Stanza::DeliveryRequest::DiscoInfoFeature->new($feature_args));
            $feature_args);
    }

    return $self;
}

sub add_identity {
    my ($self, $identity) = @_;
    push(@{ $self->{identities} }, $identity);
}

sub add_feature {
    my ($self, $feature) = @_;
    push(@{ $self->{features} }, $feature);
}

1;

