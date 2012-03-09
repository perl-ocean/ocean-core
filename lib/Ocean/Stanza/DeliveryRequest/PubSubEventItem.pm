package Ocean::Stanza::DeliveryRequest::PubSubEventItem;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';

__PACKAGE__->mk_accessors(qw(
    id
    name
    namespace
    fields
));

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    $self->{fields} ||= {};
    return $self;
}

sub keys {
    my $self = shift;
    my @keys = keys %{ $self->{fields} };
    return \@keys;
}

sub param {
    my ($self, $key, $value) = @_;
    $self->{fields}{$key} = $value if defined $value;
    return $self->{fields}{$key};
}

1;
