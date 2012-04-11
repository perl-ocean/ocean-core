package Ocean::Jingle::STUN::MessageReaderContext;

use strict;
use warnings;

use parent 'Class::Accessor::Fast';
use Ocean::Jingle::STUN::AttributeType qw(MESSAGE_INTEGRITY FINGERPRINT);
use Tie::Hash::Indexed;

__PACKAGE__->mk_accessors(qw(
    class
    method
    length    
    transaction_id
    read_bytes
    attributes
    got_message_integrity
    got_fingerprint
    unknown_attributes
));

sub new {
    my ($class, $args) = @_;
    my $self = $class->SUPER::new($args);
    $self->read_bytes('');
    $self->unknown_attributes([]);
    tie my %attrs, 'Tie::Hash::Indexed';
    $self->attributes(\%attrs);
    return $self;
}

sub has_unknown_attributes {
    my $self = shift;
    return (@{ $self->unknown_attributes } > 0);
}

sub add_unknown_attribute {
    my ($self, $attr_type) = @_;
    push @{ $self->unknown_attributes }, $attr_type;
}

sub add_attribute {
    my ($self, $type, $attr) = @_;
    if ($type eq MESSAGE_INTEGRITY) {
        $self->got_message_integrity(1);
    } elsif ($type eq FINGERPRINT) {
        $self->got_fingerprint(1);
    }
    $self->attributes->{$type} = $attr;
}

sub get_attribute {
    my ($self, $type) = @_;
    return $self->attributes->{$type};
}

sub push_bytes {
    my ($self, $bytes) = @_;
    $self->{read_bytes} .= $bytes;
}

1;
