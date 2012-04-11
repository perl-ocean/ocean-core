package Ocean::Jingle::STUN::Attribute::UnknownAttributes;

use strict;
use warnings;

use parent 'Ocean::Jingle::STUN::Attribute';
use Ocean::Jingle::STUN::AttributeType qw(UNKNOWN_ATTRIBUTES);

sub new {
    my $class = shift;
    my $self = $class->SUPER::new();
    $self->{_stash}{attributes} = [];
    return $self;
}

sub type       { UNKNOWN_ATTRIBUTES }
sub attributes { $_[0]->get('attributes') }

sub add_attributes {
    my ($self, $attr) = @_;
    push @{ $self->{_stash}{attributes} }, $attr;
}

1;
